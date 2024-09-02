//
//  UIButton+TestHelpers.swift
//  ITGWorkoutKitiOSTests
//
//  Created by Findlay Wood on 21/04/2024.
//

import UIKit

extension UIButton {
    func simulateTap() {
        simulate(event: .touchUpInside)
    }
}
