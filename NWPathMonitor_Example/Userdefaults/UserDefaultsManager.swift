//
//  UserDefaultsManager.swift
//  NWPathMonitor_Example
//
//  Created by Limefriends on 8/9/24.
//

import Foundation

struct UserDefaultsManager {
    
    
    
    @UserDefault(key: "enterTime", defaultValue: [])
    static var enterTime: [String]
    
    
    static func addEntetTime(_ time: String) {
        var times = enterTime
        times.insert(time, at: 0)
        enterTime = times
    }
    
    static func resetData() {
        UserDefaults.standard.removeObject(forKey: "enterTime")
        NotificationCenter.default.post(name: .didUpdateEnterTimes, object: nil)
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
