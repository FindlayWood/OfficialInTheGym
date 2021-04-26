//
//  LaunchMessageController.swift
//  InTheGym
//
//  Created by Findlay Wood on 22/04/2021.
//  Copyright © 2021 FindlayWood. All rights reserved.
//

import Foundation
import UIKit

extension UIApplication {
    class func isFirstLaunch() -> Bool {
        if !UserDefaults.standard.bool(forKey: "hasBeenLaunchedBeforeFlag") {
            UserDefaults.standard.set(true, forKey: "hasBeenLaunchedBeforeFlag")
            UserDefaults.standard.synchronize()
            return true
        }
        return false
    }
    
    class func isFirstDiscoverLaunch() -> Bool {
        if !UserDefaults.standard.bool(forKey: "hasDiscoverLaunchedBeforeFlag") {
            UserDefaults.standard.set(true, forKey: "hasDiscoverLaunchedBeforeFlag")
            UserDefaults.standard.synchronize()
            return true
        }
        return false
    }
    
    class func isFirstProfileLaunch() -> Bool {
        if !UserDefaults.standard.bool(forKey: "hasProfileLaunchedBeforeFlag") {
            UserDefaults.standard.set(true, forKey: "hasProfileLaunchedBeforeFlag")
            UserDefaults.standard.synchronize()
            return true
        }
        return false
    }
    
    class func isFirstWorkoutsLaunch() -> Bool {
        if !UserDefaults.standard.bool(forKey: "hasWorkoutsLaunchedBeforeFlag") {
            UserDefaults.standard.set(true, forKey: "hasWorkoutsLaunchedBeforeFlag")
            UserDefaults.standard.synchronize()
            return true
        }
        return false
    }
    
    class func isFirstPlayersLaunch() -> Bool {
        if !UserDefaults.standard.bool(forKey: "hasPlayersLaunchedBeforeFlag") {
            UserDefaults.standard.set(true, forKey: "hasPlayersLaunchedBeforeFlag")
            UserDefaults.standard.synchronize()
            return true
        }
        return false
    }
    
    
}
