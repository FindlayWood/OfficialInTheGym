//
//  UIRefreshControl+TestHelpers.swift
//  ITGWorkoutKitiOSTests
//
//  Created by Findlay Wood on 21/04/2024.
//

import UIKit

extension UIRefreshControl {
    func simulatePullToRefresh() {
        simulate(event: .valueChanged)
    }
}
