//
//  UIRefreshControl+Helpers.swift
//  ITGWorkoutKitiOS
//
//  Created by Findlay Wood on 29/04/2024.
//

import UIKit

extension UIRefreshControl {
    func update(isRefreshing: Bool) {
        isRefreshing ? beginRefreshing() : endRefreshing()
    }
}
