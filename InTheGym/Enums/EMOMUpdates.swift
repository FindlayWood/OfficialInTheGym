//
//  EMOMUpdates.swift
//  InTheGym
//
//  Created by Findlay Wood on 24/01/2022.
//  Copyright © 2022 FindlayWood. All rights reserved.
//

import Foundation

// MARK: - EMOM Update Type
/// All the ways an emom can be updated
enum EMOMUpdateType: Codable {
    case completed
    case rpe(Int)
}
