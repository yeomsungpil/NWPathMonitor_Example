
import UIKit
import FSCalendar
import SnapKit

class ViewController: UIViewController {
    
    var enterEnterOfficeTime: String?
    var leaveOfficeTime: String?
    
    var selectedDate = Date()
    
    var calendarHeightConstraint: Constraint? // 캘린더 높이 제약 조건을 저장할 변수
    let currentCalendar = Calendar.current
    
    var enterTimeDatesSet: Set<Date> = [] // 시간 복잡도를 줄이기 위해 Set 사용
    
    
    
    lazy var calendar: FSCalendar = {
        let calendar = FSCalendar(frame: CGRect(x: 0, y: 0, width: UIScreen.main.bounds.width, height: 150))
        calendar.scope = .week
        calendar.locale = Locale(identifier: "ko_KR")
        calendar.appearance.headerDateFormat = "YYYY.M"
        calendar.appearance.headerMinimumDissolvedAlpha = 0.0
//        calendar.backgroundColor = .yellow
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
    
    lazy var enterCheckTextLabel: UILabel = {
       let label = UILabel()
        label.text = "출근 임시 값"
        label.font = UIFont.systemFont(ofSize: 10, weight: .semibold)
        return label
    }()
    
    lazy var leaveCheckTextLabel: UILabel = {
       let label = UILabel()
        label.text = "퇴근 임시 값"
        label.font = UIFont.systemFont(ofSize: 20, weight: .semibold)
        return label
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
        setSwipeCalendarHeight()

    }
    
    private func setSwipeCalendarHeight() {
        let swipeUp = UISwipeGestureRecognizer(target: self, action: #selector(swipeEvent(_:)))
        swipeUp.direction = .up
        self.calendar.addGestureRecognizer(swipeUp)
        
        let swipeDown = UISwipeGestureRecognizer(target: self, action: #selector(swipeEvent(_:)))
        swipeDown.direction = .down
        self.calendar.addGestureRecognizer(swipeDown)
    }
    
    @objc
    func swipeEvent(_ swipe: UISwipeGestureRecognizer) {
        let newScope: FSCalendarScope = swipe.direction == .up ? .week : .month
        calendar.setScope(newScope, animated: true)
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
        
        DispatchQueue.main.async {
            self.enterCheckTextLabel.text = "범위에 들어왔습니다. 출근했습니다."
        }
    }
    
    @objc
    func reloadLeaveTableView() {
        self.leaveOfficeTime = isDateIncluded(for: Date(), in: .leave).first
        self.tableView.reloadRows(at: [IndexPath(row: 0, section: 1)], with: .automatic)
        
        DispatchQueue.main.async {
            self.leaveCheckTextLabel.text = "범위를 벗어났습니다. 퇴근했습니다."
        }
        
    }
    
    
    
    
    fileprivate func setup() {
        view.backgroundColor = .white
        [calendar, tableView, enterCheckTextLabel, leaveCheckTextLabel].forEach {
            self.view.addSubview($0)
        }
        calendar.delegate = self
        calendar.dataSource = self
        // 날짜에서 시간 정보를 제거한 후 Set에 저장
        enterTimeDatesSet = Set(UserDefaultsManager.enterTimeDatas.map { currentCalendar.startOfDay(for: $0)})
    }
    
    fileprivate func setupLayout() {
        calendar.snp.makeConstraints { make in
            make.top.leading.trailing.equalTo(self.view.safeAreaLayoutGuide)
            self.calendarHeightConstraint = make.height.equalTo(400).constraint // 초기 높이 제약 조건을 변수에 저장

        }
        
        tableView.snp.makeConstraints { make in
            make.top.equalTo(self.calendar.snp.bottom)
            make.leading.trailing.equalTo(self.view.safeAreaLayoutGuide)
            make.height.equalTo(250)
        }
        
        enterCheckTextLabel.snp.makeConstraints { make in
            make.top.equalTo(self.tableView.snp.bottom).offset(10)
            make.leading.equalTo(self.tableView.snp.leading).offset(10)
        }
        
        leaveCheckTextLabel.snp.makeConstraints { make in
            make.top.equalTo(self.enterCheckTextLabel.snp.bottom).offset(10)
            make.leading.equalTo(enterCheckTextLabel)
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

extension ViewController: FSCalendarDelegate, FSCalendarDataSource {
    func calendar(_ calendar: FSCalendar, numberOfEventsFor date: Date) -> Int {
        
        let dateWithoutTime = currentCalendar.startOfDay(for: date)
        return enterTimeDatesSet.contains(dateWithoutTime) ? 1: 0
    }
    
    func calendar(_ calendar: FSCalendar, appearance: FSCalendarAppearance, eventDefaultColorsFor date: Date) -> [UIColor]? {
        
        let dateWithoutTime = currentCalendar.startOfDay(for: date)
        return enterTimeDatesSet.contains(dateWithoutTime) ? [UIColor.green] : nil
    }
    
    func calendar(_ calendar: FSCalendar, willDisplay cell: FSCalendarCell, for date: Date, at monthPosition: FSCalendarMonthPosition) {
        let eventScaleFactor: CGFloat = 1.8
        cell.eventIndicator.transform = CGAffineTransform(scaleX: eventScaleFactor, y: eventScaleFactor)
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
