//
//  SavedWorkoutCreatorKeyModel.swift
//  InTheGym
//
//  Created by Findlay Wood on 18/04/2022.
//  Copyright © 2022 FindlayWood. All rights reserved.
//

import Foundation

struct SavedWorkoutCreatorKeyModel {
    var id: String
}
extension SavedWorkoutCreatorKeyModel: FirebaseInstance {
    var internalPath: String {
        return "SavedWorkoutCreators/\(id)"
    }
}
