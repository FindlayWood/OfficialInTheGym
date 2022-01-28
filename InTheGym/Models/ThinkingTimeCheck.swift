//
//  ThinkingTimeCheck.swift
//  InTheGym
//
//  Created by Findlay Wood on 27/01/2022.
//  Copyright © 2022 FindlayWood. All rights reserved.
//

import Foundation

// MARK: - Thinking Time Check Model
///Model used to check whether thinking time is active
struct ThinkingTimeCheckModel {
    var isActive: Bool
}
extension ThinkingTimeCheckModel: FirebaseModel {
    static var path: String {
        return "ThinkingTime"
    }
}
