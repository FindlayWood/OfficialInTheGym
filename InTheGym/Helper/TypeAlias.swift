//
//  TypeAlias.swift
//  InTheGym
//
//  Created by Findlay Wood on 21/02/2022.
//  Copyright © 2022 FindlayWood. All rights reserved.
//

import Foundation
import Combine

/// PassThroughSubject with value of WorkoutModel
/// Workout Creation sends the newly created workout to this type
/// Any VC contain a list of workouts should pass a value of this type to workout Creation VC to listen for updates
typealias WorkoutList = PassthroughSubject<WorkoutModel,Never>

typealias PostListener = PassthroughSubject<PostModel,Never>

typealias GroupPostListener = PassthroughSubject<GroupPost,Never>

/// Listen for saved workout being removed from list
typealias SavedWorkoutRemoveListener = PassthroughSubject<SavedWorkoutModel,Never>


typealias WorkoutUpdatedListener = PassthroughSubject<WorkoutModel,Never>

/// Listen for a new post being added
typealias NewPostListener = PassthroughSubject<Postable,Never>

/// Listen for a new description being added
typealias NewCommentListener = PassthroughSubject<String,Never>
