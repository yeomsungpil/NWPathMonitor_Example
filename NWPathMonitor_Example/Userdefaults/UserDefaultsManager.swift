//
//  UserDefaultsManager.swift
//  NWPathMonitor_Example
//
//  Created by Limefriends on 8/9/24.
//

import Foundation

struct UserDefaultsManager {
    
    
    
    @UserDefault(key: "enterTime", defaultValue: [])
    static var enterTimeDatas: [Date]
    
    @UserDefault(key: "leaveTime", defaultValue: [])
    static var leaveTimeDatas: [Date]
    
    static func addEnterTime(_ time: Date) {
        if !enterTimeDatas.contains(where: { isSameDay($0, time) }) {
            enterTimeDatas.append(time)
        }
    }

    static func addLeaveTime(_ time: Date) {
        if !leaveTimeDatas.contains(where: { isSameDay($0, time) }) {
            leaveTimeDatas.append(time)
        }
    }

    static func isSameDay(_ date1: Date, _ date2: Date) -> Bool {
        let calendar = Calendar.current
        return calendar.isDate(date1, inSameDayAs: date2)
    }
    
    
    static func resetData() {
        UserDefaults.standard.removeObject(forKey: "enterTime")
        UserDefaults.standard.removeObject(forKey: "leaveTime")
        enterTimeDatas = []
        leaveTimeDatas = []
    }
}

extension Notification.Name {
    static let didUpdateEnterTimes = Notification.Name("didUpdateEnterTimes")
    static let didUpdateLeaveTimes = Notification.Name("didUpdateLeaveTimes")
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
