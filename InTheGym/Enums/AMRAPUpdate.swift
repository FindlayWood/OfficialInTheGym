//
//  AMRAPUpdate.swift
//  InTheGym
//
//  Created by Findlay Wood on 24/01/2022.
//  Copyright © 2022 FindlayWood. All rights reserved.
//

import Foundation

// MARK: - AMRAP Update Type
///All the different ways an amrap can be updated
enum AMRAPUpdateType: Codable {
    case rounds
    case exercises
    case completed
    case rpe(Int)
}
