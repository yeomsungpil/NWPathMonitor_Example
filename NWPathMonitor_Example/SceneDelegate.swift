//
//  SceneDelegate.swift
//  NWPathMonitor_Example
//
//  Created by Limefriends on 7/22/24.
//

import UIKit
import NetworkExtension
import CoreLocation
import SystemConfiguration.CaptiveNetwork

class SceneDelegate: UIResponder, UIWindowSceneDelegate, CLLocationManagerDelegate {

    var window: UIWindow?
    var errorWindow: UIWindow? // 연결이 끊겼을때 나타날 Window 창
    var networkMonitor: NetworkMonitor = NetworkMonitor()
    var locationManager: CLLocationManager?


    func scene(_ scene: UIScene, willConnectTo session: UISceneSession, options connectionOptions: UIScene.ConnectionOptions) {
        
        // iOS 13.0 이상 부터 애플: 프라이버시 보호를 위해 위치 권한 필요, WiFi 네트워크가 사용자의 위치를 어느정도 유추 할 수 있기 때문에, 명시적으로 권한을 부여한 경우에만 SSID 정보에 접근 할 수 있도록 제한
        locationManager = CLLocationManager()
        locationManager?.delegate = self
        locationManager?.requestWhenInUseAuthorization()
        
        networkMonitor.startMonitoring { [weak self] connectionOptions in
            switch connectionOptions {
            case .satisfied:
                self?.removeNetworkErrorWindow()
                print("dismiss networkerror View if is present")
                self?.fetchCurrentWiFiSSID()
            case .unsatisfied:
                self?.loadNetworkErrorWindow(on: scene)
                print("No Internet! show network Error View")
            case .requiresConnection:
                print("requiresConnection")
            default:
                break
            }
        }
        
        guard let windowScene = (scene as? UIWindowScene) else { return }
        window = UIWindow(windowScene: windowScene)
        let mainViewController = ViewController()
        
        window?.rootViewController = UINavigationController(rootViewController: mainViewController)
        window?.makeKeyAndVisible()
    }
    

    private func companyLocation() {
        // 회사 위치
        let regionCenter = CLLocationCoordinate2D(latitude: 37.467640, longitude: 126.888187)
        
        // 회사 반경
        let regionRadius : CLLocationDistance = 1
        
        let region = CLCircularRegion(center: regionCenter, radius: regionRadius, identifier: "Company")
        region.notifyOnExit = true // 해당 영역에서 벗어났을때 이벤트 발생
        
        // 지정된 영역 모니터링 시작
        locationManager?.startMonitoring(for: region)
    }
    
    private func loadNetworkErrorWindow(on scene: UIScene) {
        
        if let windowScene = scene as? UIWindowScene {
            // 새로운 윈도우 창 만들기
            let window = UIWindow(windowScene: windowScene)
            window.windowLevel = .statusBar // 창이 다른 차들 위에 표시되는 순서
            window.makeKeyAndVisible()
            
            let noNetworkView = NoNetworkView(frame: window.bounds)
            // 해당 윈도우 위에 noNetworkView 올리기
            window.addSubview(noNetworkView)
            self.errorWindow = window
        }
    }
    
    private func removeNetworkErrorWindow() {
        errorWindow?.resignKey() // keyWindow로부터 해지
        errorWindow?.isHidden = true // 화면에서 제거 
        errorWindow = nil // 리소스 제거
    }

    func sceneDidDisconnect(_ scene: UIScene) {
        networkMonitor.stopMonitoring()
    }
    
    // CLlocation 권한 설정에 따른 SSID fetch 유무
    func locationManagerDidChangeAuthorization(_ manager: CLLocationManager) {
        switch manager.authorizationStatus {
        case .notDetermined:
            print("notDetermined")
        case .restricted:
            print("restricted")
        case .denied:
            print("denied")
        case .authorizedAlways, .authorizedWhenInUse, .authorized:
//            fetchCurrentWiFiSSID()
            print("conntect Location")
        @unknown default:
            break
        }
    }
    
    func locationManager(_ manager: CLLocationManager, didExitRegion region: CLRegion) {
        if region.identifier == "Company" {
            print("퇴근했습니다.")
            
            let leaveTime = Date()
            UserDefaultsManager.addLeaveTime(leaveTime)
            NotificationCenter.default.post(name: .didUpdateLeaveTimes, object: nil)
            locationManager?.stopUpdatingLocation()
        }
    }
    
    private func fetchCurrentWiFiSSID() {
        if let ssid = getWiFiSSID() {
            print("Connected Wi-Fi SSID: \(ssid)")
            if ssid.contains("LIME") {
                print(Date().formatted())
                print("출석 체크")
                UserDefaultsManager.addEnterTime(Date())
                NotificationCenter.default.post(name: .didUpdateEnterTimes, object: nil)
            }
        } else {
            
            print("Not connected to any Wi-Fi. 끊긴 시간 : ")
            companyLocation()
        }
    }

    private func getWiFiSSID() -> String? {
        var ssid: String?
        // Wi-Fi 인터페이스 목록 가져오기
        // CNCopySupportedInterfaces : 현재 사용 가능한 WiFi 네트워크 인터페이스의 목록 반환
        if let interfaces = CNCopySupportedInterfaces() as NSArray? {
            for interface in interfaces {
                // CNCopyCurrentNetworkInfo(CFString) : 인터페이스에 대한 네트워크 정보 반환 SSID, BSSID 정보 포함됌
                // interfaceInfo : 딕셔너리 형태로 구성 [ SSID ( or BBID ) , 네트워크 name ]
                if let interfaceInfo = CNCopyCurrentNetworkInfo(interface as! CFString) as NSDictionary? {
                    ssid = interfaceInfo[kCNNetworkInfoKeySSID as String] as? String
                    break
                }
            }
        }
        return ssid
    }


    func sceneDidBecomeActive(_ scene: UIScene) {
        // Called when the scene has moved from an inactive state to an active state.
        // Use this method to restart any tasks that were paused (or not yet started) when the scene was inactive.
    }

    func sceneWillResignActive(_ scene: UIScene) {
        // Called when the scene will move from an active state to an inactive state.
        // This may occur due to temporary interruptions (ex. an incoming phone call).
    }

    func sceneWillEnterForeground(_ scene: UIScene) {
        // Called as the scene transitions from the background to the foreground.
        // Use this method to undo the changes made on entering the background.
    }

    func sceneDidEnterBackground(_ scene: UIScene) {
        // 백그라운드 상태일때도 Network 실행
        fetchCurrentWiFiSSID()
    }


}


