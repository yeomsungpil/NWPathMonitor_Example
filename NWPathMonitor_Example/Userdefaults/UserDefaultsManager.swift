//
//  UserDefaultsManager.swift
//  NWPathMonitor_Example
//
//  Created by Limefriends on 8/9/24.
//

import Foundation

struct UserDefaultsManager {
    
    
    
    @UserDefault(key: "enterTime", defaultValue: [])
    static var enterTimeDatas: [String]
    
    
    static func addEnterTime(_ time: String) {
        
        let currentDate = Date().formatted(.dateTime.locale(Locale(identifier: "ko_KR")).day().month(.twoDigits).year())
        let stringDate = String(describing: currentDate)
        let prefixStringDate = String(stringDate.prefix(12))
        
        // 배열안에 prefixStringDate로 시작하는 문자열이 하나라도 없을때
        if !enterTimeDatas.contains(where: {
            $0.hasPrefix(prefixStringDate)
        }) {
            enterTimeDatas.append(time)
        }
    }
    
    
    static func resetData() {
        UserDefaults.standard.removeObject(forKey: "enterTime")
        enterTimeDatas = []
    }
}

extension Notification.Name {
    static let didUpdateEnterTimes = Notification.Name("didUpdateEnterTimes")
}


@propertyWrapper
struct UserDefault<T: Codable> {
    private var key: String
    private var defaultValue: T
    
    init(key: String, defaultValue: T) {
        self.key = key
        self.defaultValue = defaultValue
    }
    
    var wrappedValue: T {
        get {
            guard let data = UserDefaults.standard.data(forKey: key) else { return defaultValue }
            
            let decodedValue = try? JSONDecoder().decode(T.self, from: data)
            return decodedValue ?? defaultValue
        }
        
        set {
            let data = try? JSONEncoder().encode(newValue)
            UserDefaults.standard.setValue(data, forKey: key)
        }
    }
}
