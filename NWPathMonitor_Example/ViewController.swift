//
//  ViewController.swift
//  NWPathMonitor_Example
//
//  Created by Limefriends on 7/22/24.
//

import UIKit
import FSCalendar

class ViewController: UIViewController {
    
    var enterTimeOfficeArray: [String] = []
    
    var selectedDate = Date()
    
    lazy var calendar: FSCalendar = {
        let calendar = FSCalendar(frame: .zero)
        calendar.scope = .week
        calendar.locale = Locale(identifier: "ko_KR")
        calendar.appearance.headerDateFormat = "YYYY.M"
        calendar.appearance.headerMinimumDissolvedAlpha = 0.0
//        calendar.firstWeekday = 2
//        calendar.backgroundColor = .yellow
//        calendar.appearance.weekdayTextColor = .label
        
        // 캘린더의 행 높이를 조정합니다.
        calendar.rowHeight = 30
        
        // 헤더의 높이를 조정합니다.
        calendar.headerHeight = 20
        // 요일 레이블의 높이를 조정합니다.
        calendar.weekdayHeight = 20
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
        
        // 데이터가 변경되었음을 알리는 Notification 발송
        NotificationCenter.default.addObserver(self, selector: #selector(reloadTableView), name: .didUpdateEnterTimes, object: nil)
        navigationItem.rightBarButtonItem = UIBarButtonItem(title: "reset", style: .plain, target: self, action: #selector(resetUserDefault))
    }
    
    @objc
    func resetUserDefault() {
        self.enterTimeOfficeArray = []
        UserDefaultsManager.resetData()
    }
    
    @objc
    func reloadTableView() {
        print("enterTimeOfficeArray : \(enterTimeOfficeArray.count)")
        self.enterTimeOfficeArray = isDateIncluded(date: Date())
        self.tableView.reloadData()
        
    }
    
    
    
    fileprivate func setup() {
        view.backgroundColor = .white
        self.view.addSubview(calendar)
        self.view.addSubview(tableView)
    }
    
    fileprivate func setupLayout() {
        calendar.snp.makeConstraints { make in
            make.top.leading.trailing.equalTo(self.view.safeAreaLayoutGuide)
            make.height.equalTo(150)  // 높이를 150으로 설정
        }
        tableView.snp.makeConstraints { make in
            make.top.equalTo(self.calendar.snp.bottom)
            make.leading.trailing.bottom.equalTo(self.view.safeAreaLayoutGuide)
        }
    }
    
    fileprivate func isDateIncluded(date: Date) -> [String] {
        let didSelectDate = date.formatted(.dateTime.locale(Locale(identifier: "ko_KR")).day().month(.twoDigits).year())
        let stringDate = String(describing: didSelectDate)
        let prefixStringDate = String(stringDate.prefix(12))
        
        return UserDefaultsManager.enterTimeDatas.filter { $0.hasPrefix(prefixStringDate) }
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
        let didSelectDate = date.formatted(.dateTime.locale(Locale(identifier: "ko_KR")).day().month(.twoDigits).year())
        let stringDate = String(describing: didSelectDate)
        let prefixStringDate = String(stringDate.prefix(12))
        
        self.enterTimeOfficeArray = isDateIncluded(date: date)
        
        self.tableView.reloadData()
    }
    
}


extension ViewController: UITableViewDelegate, UITableViewDataSource {
 
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        print("갯수 : \(enterTimeOfficeArray.count)")
        return enterTimeOfficeArray.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        guard let cell = tableView.dequeueReusableCell(withIdentifier: EnterOfficeTimeCell.identifier, for: indexPath) as? EnterOfficeTimeCell else { return UITableViewCell() }
        
        cell.timeLabel.text = enterTimeOfficeArray[indexPath.row]
        cell.selectionStyle = .none
        return cell
    }
    
    func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        return "출근 시간"
    }
}
