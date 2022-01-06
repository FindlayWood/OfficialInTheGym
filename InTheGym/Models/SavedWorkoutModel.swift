//
//  SavedWorkoutModel.swift
//  InTheGym
//
//  Created by Findlay Wood on 05/01/2022.
//  Copyright © 2022 FindlayWood. All rights reserved.
//

import Foundation

class SavedWorkoutModel: Codable {
    var id: String
    var title: String
    var createdBy: String
    var creatorID: String
    var isPrivate: Bool
    var Views: Int
    var NumberOfDownloads: Int
    var NumberOfCompletes: Int
    var TotalScore: Int
    var TotalTime: Int
}
