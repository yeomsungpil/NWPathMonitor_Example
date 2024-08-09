//
//  EnterOfficeTimeCell.swift
//  NWPathMonitor_Example
//
//  Created by Limefriends on 8/9/24.
//

import UIKit


class EnterOfficeTimeCell: UITableViewCell {
    
    static let identifier = "EnterOfficeTimeCell"
    
    lazy var timeLabel: UILabel = {
       let label = UILabel()
        label.font = UIFont.systemFont(ofSize: 20, weight: .medium)
        return label
    }()
    
    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        self.contentView.addSubview(timeLabel)
        
        timeLabel.snp.makeConstraints { make in
            make.leading.equalToSuperview().inset(10)
            make.centerY.equalToSuperview()
        }
    }
    
    func setup(data: String) {
        self.timeLabel.text = data
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}
