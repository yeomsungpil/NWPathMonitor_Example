//
//  NoNetworkView.swift
//  NWPathMonitor_Example
//
//  Created by Limefriends on 7/22/24.
//

import UIKit
import SnapKit

class NoNetworkView: UIView {
    
    var baseView: UIView = {
        let view = UIView(frame: CGRect(x: UIScreen.main.bounds.minX, y: UIScreen.main.bounds.minY, width: UIScreen.main.bounds.width, height: UIScreen.main.bounds.height))
        view.backgroundColor = .yellow
        view.layer.cornerRadius = 20
        view.layer.cornerCurve = .continuous
        view.clipsToBounds = true
        return view
    }()
    
    var notEnterTheOfficeTextLabel: UILabel = {
       let label = UILabel()
        label.font = UIFont.systemFont(ofSize: 30, weight: .semibold)
        label.text = "아직 출근 전이에요!"
        return label
    }()
    
    
    override init(frame: CGRect) {
        super.init(frame: frame)
//        self.addSubview(baseView)
        self.addSubview(notEnterTheOfficeTextLabel)
        
        notEnterTheOfficeTextLabel.snp.makeConstraints { make in
            make.center.equalToSuperview()
        }
        
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}
