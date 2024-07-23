//
//  ViewController.swift
//  NWPathMonitor_Example
//
//  Created by Limefriends on 7/22/24.
//

import UIKit

/*
 🔴 BaseVC에 상속받은 객체에서 NWPathMonitor 객체를 생성하게 된다면, 리소스 낭비 EX) 100개 만들고 100개 지우는 작업 필요
 
 ==>
 */


class BaseViewController: UIViewController {

    private let networkMonitor = NetworkMonitor()
    
    private var noNetworkView: NoNetworkView = {
       let view = NoNetworkView()
        return view
    }()
    
    deinit {
        networkMonitor.stopMonitoring()
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        networkMonitor.startMonitoring { [weak self] connectionStatus in
           
            switch connectionStatus {
            case .satisfied:
                print("dismiss networkError view if is present")
            case .unsatisfied:
                self?.showNoNetworkView()
                print("NO Internet! show network Error view")
            case .requiresConnection:
                self?.dismissNoNetworkView()
                print("requiresConnection")
            default:
                break
            }
            
        }
    }
    
    private func showNoNetworkView() {
        if let windowScene = UIApplication.shared.connectedScenes.first as? UIWindowScene,
           let keyWindow = windowScene.keyWindow {
            keyWindow.addSubview(noNetworkView)
            keyWindow.bringSubviewToFront(noNetworkView)
        } else {
            print("either no connectedScene or no keyWindow available")
        }
    }
    
    private func dismissNoNetworkView() {
        if let windowScene = UIApplication.shared.connectedScenes.first as? UIWindowScene,
           let keyWindow = windowScene.keyWindow {
            // 최상단 뷰가 noNetworkView인지 판단하는 로직 필요
            guard let noNetworkView = keyWindow.subviews.last as? NoNetworkView else {
                print("the presenting view is not noNetworking")
                return
            }
            
            noNetworkView.removeFromSuperview()
        }
    }


}

