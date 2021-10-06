//
//  ProgramModel.swift
//  InTheGym
//
//  Created by Findlay Wood on 13/09/2021.
//  Copyright © 2021 FindlayWood. All rights reserved.
//

import Foundation

/// the model for workout programs - these are several weeks worth of workouts
class ProgramModel: Codable, AutoIDable {
    var title: String
    var numberOfWeeks: Int
    var creatorID: String
    var createdBy: String
    var id: String
}
