//
//  WorkoutOptionsModel.swift
//  InTheGym
//
//  Created by Findlay Wood on 12/01/2022.
//  Copyright © 2022 FindlayWood. All rights reserved.
//

import Foundation

// MARK: - WorkoutOptions Model
/// Holds the options for a workout
/// isPrivate - true means that the workout is only viewable by the creator and any user who has been assigned the workout
/// save - true to add the workout to the users saved wrokout references

struct WorkoutOptionsModel {
    var isPrivate: Bool
    var save: Bool
}
