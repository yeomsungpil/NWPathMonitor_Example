
import UIKit
import FSCalendar
import SnapKit

class ViewController: UIViewController {
    
    var enterEnterOfficeTime: String?
    var leaveOfficeTime: String?
    
    var selectedDate = Date()
    
    var calendarHeightConstraint: Constraint? // 캘린더 높이 제약 조건을 저장할 변수
    
    lazy var calendar: FSCalendar = {
        let calendar = FSCalendar(frame: CGRect(x: 0, y: 0, width: UIScreen.main.bounds.width, height: 150))
        calendar.scope = .week
        calendar.locale = Locale(identifier: "ko_KR")
        calendar.appearance.headerDateFormat = "YYYY.M"
        calendar.appearance.headerMinimumDissolvedAlpha = 0.0
        calendar.backgroundColor = .yellow
        calendar.delegate = self
        return calendar
    }()
    
    
    lazy var tableView: UITableView = {
       let table = UITableView()
        table.rowHeight = 60
        table.delegate = self
        table.dataSource = self
        table.separatorStyle = .none
        table.isScrollEnabled = false
        table.register(EnterOfficeTimeCell.self, forCellReuseIdentifier: EnterOfficeTimeCell.identifier)
        return table
    }()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        print(#function)
        navigationItem.title = "나의 라임 ( Rhyme )"
        setup()
        setupLayout()
        self.enterEnterOfficeTime = isDateIncluded(for: Date(), in: .enter).first
        self.leaveOfficeTime = isDateIncluded(for: Date(), in: .leave).first
        // 데이터가 변경되었음을 알리는 Notification 발송
        NotificationCenter.default.addObserver(self, selector: #selector(reloadEnterTableView), name: .didUpdateEnterTimes, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(reloadLeaveTableView), name: .didUpdateLeaveTimes, object: nil)

        navigationItem.rightBarButtonItem = UIBarButtonItem(title: "reset", style: .plain, target: self, action: #selector(resetUserDefault))
    }
    
    @objc
    func resetUserDefault() {
        UserDefaultsManager.resetData()
        enterEnterOfficeTime = nil
        leaveOfficeTime = nil
    }
    
    @objc
    func reloadEnterTableView() {
        self.enterEnterOfficeTime = isDateIncluded(for: Date(), in: .enter).first
        self.tableView.reloadRows(at: [IndexPath(row: 0, section: 0)], with: .automatic)
    }
    
    @objc
    func reloadLeaveTableView() {
        self.leaveOfficeTime = isDateIncluded(for: Date(), in: .leave).first
        self.tableView.reloadRows(at: [IndexPath(row: 0, section: 1)], with: .automatic)
        
    }
    
    
    
    
    fileprivate func setup() {
        view.backgroundColor = .white
        self.view.addSubview(calendar)
        self.view.addSubview(tableView)
    }
    
    fileprivate func setupLayout() {
        calendar.snp.makeConstraints { make in
            make.top.leading.trailing.equalTo(self.view.safeAreaLayoutGuide)
            self.calendarHeightConstraint = make.height.equalTo(400).constraint // 초기 높이 제약 조건을 변수에 저장

        }
        tableView.snp.makeConstraints { make in
            make.top.equalTo(self.calendar.snp.bottom)
            make.leading.trailing.bottom.equalTo(self.view.safeAreaLayoutGuide)
        }
    }
    
    fileprivate func isDateIncluded(for date: Date?, in dataType: DataType) -> [String] {
        guard let date = date else { return [""] }
        
        let dataArray: [Date]
        
        switch dataType {
        case .enter:
            dataArray = UserDefaultsManager.enterTimeDatas
        case .leave:
            dataArray = UserDefaultsManager.leaveTimeDatas
        }
        
        return dataArray
            .filter { UserDefaultsManager.isSameDay($0, date) }
            .map { $0.formatted(.dateTime.locale(Locale(identifier: "ko_KR")).day().month(.twoDigits).year().hour().minute()) }
    }
}

extension ViewController: FSCalendarDelegateAppearance {
    // 토요일 파랑, 일요일 빨강으로 만들기
    func calendar(_ calendar: FSCalendar, appearance: FSCalendarAppearance, titleDefaultColorFor date: Date) -> UIColor? {
        let day = Calendar.current.component(.weekday, from: date) - 1
//        let isActive = activeDates.contains(date)
//        let alpha: CGFloat = isActive ? 1.0 : 0.2
        switch Calendar.current.shortWeekdaySymbols[day] {
        case "Sun":
            return UIColor.systemRed.withAlphaComponent(1.0)
        case "Sat":
            return UIColor.systemBlue.withAlphaComponent(1.0)
        default:
            return UIColor.label.withAlphaComponent(1.0)
        }
    }
    
    func calendar(_ calendar: FSCalendar, didSelect date: Date, at monthPosition: FSCalendarMonthPosition) {
        self.enterEnterOfficeTime = isDateIncluded(for: date, in: .enter).first
        self.leaveOfficeTime = isDateIncluded(for: date, in: .leave).first
        self.tableView.reloadData()
    }
    
    func calendar(_ calendar: FSCalendar, boundingRectWillChange bounds: CGRect, animated: Bool) {
        self.calendarHeightConstraint?.update(offset: bounds.height) // 높이 제약 조건 업데이트
        self.view.layoutIfNeeded()
    }
    
}


extension ViewController: UITableViewDelegate, UITableViewDataSource {
    
    func numberOfSections(in tableView: UITableView) -> Int {
        if leaveOfficeTime != nil  {
            return 2
        } else {
            return 1
        }
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return 1
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        guard let cell = tableView.dequeueReusableCell(withIdentifier: EnterOfficeTimeCell.identifier, for: indexPath) as? EnterOfficeTimeCell else { return UITableViewCell() }
        
        if leaveOfficeTime == nil {
            cell.timeLabel.text = self.enterEnterOfficeTime ?? "출근 전 입니다."
        } else {
            switch indexPath.section {
            case 0:
                cell.timeLabel.text = enterEnterOfficeTime ?? "출근 전 입니다."
            case 1:
                cell.timeLabel.text = leaveOfficeTime ?? "퇴근 전 입니다."
            default:
                return cell
            }
        }
       
        cell.selectionStyle = .none
        return cell
    }
    
    func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        
        switch section {
        case 0:
            return "출근 시간"
        case 1:
            return "퇴근 시간"
        default:
            return "잘못된 값"
        }
    }
}
