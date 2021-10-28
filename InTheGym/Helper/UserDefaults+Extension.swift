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

extension UserDefaults {
    
    enum Keys: String {
        case hasSeenIntroductionPage = "hasSeenIntroductionPage"
        case currentUsername = "currentUsername"
    }
    
    @UserDefault(key: Keys.hasSeenIntroductionPage.rawValue, defaultValue: false)
    static var hasSeenIntroduction: Bool
    
    @UserDefault(key: Keys.currentUsername.rawValue, defaultValue: "")
    static var currentUsername: String
    
}

@propertyWrapper
struct UserDefault<Value> {
    let key: String
    let defaultValue: Value
    
    init(key: String, defaultValue: Value) {
        self.key = key
        self.defaultValue = defaultValue
    }
    
    var wrappedValue: Value {
        get {
            (UserDefaults.standard.object(forKey: self.key) as? Value) ?? self.defaultValue
        }
        set {
            UserDefaults.standard.set(newValue, forKey: self.key)
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
