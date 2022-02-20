//
//  ExerciseClipsModel.swift
//  InTheGym
//
//  Created by Findlay Wood on 17/02/2022.
//  Copyright © 2022 FindlayWood. All rights reserved.
//

import Foundation

// MARK: - Exercise Clips Model
/// Model to retreive all clips for given exercise
/// Will return array of KeyClipModel containg clipKey and storageURL
struct ExerciseClipsModel {
    var exerciseName: String
}
extension ExerciseClipsModel: FirebaseInstance {
    var internalPath: String {
        return "ExerciseClips/\(exerciseName)"
    }
}
