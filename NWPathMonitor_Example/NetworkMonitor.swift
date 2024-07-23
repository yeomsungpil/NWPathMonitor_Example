//
//  NetworkMonitor.swift
//  NWPathMonitor_Example
//
//  Created by Limefriends on 7/22/24.
//

import Foundation
import Network

final class NetworkMonitor {
    
    private let queue = DispatchQueue.global(qos: .background)
    private let monitor: NWPathMonitor // 네트워크 변화를 감지
    
    init() {
        
        /*
         WiFi만 모니터링 할것이기 때문에 특정한 타입으로 설정 <=> 매개변수로 들어간 Interface는 제외 NWPathMonitor(prohibitedInterfaceTypes: <#T##[NWInterface.InterfaceType]#>)
         */
        monitor = NWPathMonitor(requiredInterfaceType: .wifi)
        
        dump(monitor)
        print("--------------")
    }
    
    func startMonitoring(statusUpdateHandler: @escaping (NWPath.Status) -> Void) {
        // 네트워크 경로 업데이트를 수신
        monitor.pathUpdateHandler = { path in
            DispatchQueue.main.async {
                // 다른 곳에서 사용하기 위해 @escaping 클로저 사용
                statusUpdateHandler(path.status)
            }
        }
        // 모니터링 시작 및 경로 이벤트를 전달할 대기열 설정
        monitor.start(queue: queue)
    }
    
    // 모니터링 종료
    func stopMonitoring() {
        monitor.cancel()
    }
}
