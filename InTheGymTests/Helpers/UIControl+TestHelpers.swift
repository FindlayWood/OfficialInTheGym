//
//  UIControl+TestHelpers.swift
//  ITGWorkoutKitiOSTests
//
//  Created by Findlay Wood on 21/04/2024.
//

import UIKit

extension UIControl {
    func simulate(event: UIControl.Event) {
        allTargets.forEach { target in
            actions(forTarget: target, forControlEvent: event)?.forEach {
                (target as NSObject).perform(Selector($0))
            }
        }
    }
}
