//
//  UserDefaults+Extension.swift
//  InTheGym
//
//  Created by Findlay Wood on 25/10/2021.
//  Copyright © 2021 FindlayWood. All rights reserved.
//

import Foundation
import Accessibility
import UIKit

// MARK: - Extend User Defaults
///Add custom settings for each user
extension UserDefaults {
    
    enum Keys: String {
        case hasSeenIntroductionPage = "hasSeenIntroductionPage"
        case currentUsername = "currentUsername"
        case currentUser = "currentUser"
    }
    
    @UserDefaultWrapper(key: Keys.hasSeenIntroductionPage.rawValue, defaultValue: false)
    static var hasSeenIntroduction: Bool
    
    @UserDefaultWrapper(key: Keys.currentUsername.rawValue, defaultValue: "")
    static var currentUsername: String
    
    @UserDefaultWrapper(key: Keys.currentUser.rawValue, defaultValue: Users.nilUser)
    static var currentUser: Users
    
    
}


// MARK: - User Defaults Property Wrapper
///When setting or getting a userdefaults value this wrapper will intercept the operation and update User Defaults in the background
///The generic value must be codable to allow for custom objects
@propertyWrapper
struct UserDefaultWrapper<Value: Codable> {
    let key: String
    let defaultValue: Value
    
    init(key: String, defaultValue: Value) {
        self.key = key
        self.defaultValue = defaultValue
    }
    
    var wrappedValue: Value {
        get {
            // Read value from UserDefaults
            guard let data = UserDefaults.standard.object(forKey: key) as? Data else {
                // Return defaultValue when no data in UserDefaults
                return defaultValue
            }
            
            // Convert data to the desire data type
            let value = try? JSONDecoder().decode(Value.self, from: data)
            return value ?? defaultValue
            
//            (UserDefaults.standard.object(forKey: self.key) as? Value) ?? self.defaultValue
        }
        set {
            // Convert newValue to data
            let data = try? JSONEncoder().encode(newValue)
            
            // Set value to UserDefaults
            UserDefaults.standard.set(data, forKey: key)
//            UserDefaults.standard.set(newValue, forKey: self.key)
        }
    }
    
    var projectValue: Self {
        get {
            return self
        }
    }
    
    func removeValue() {
        UserDefaults.standard.removeObject(forKey: self.key)
    }
}
