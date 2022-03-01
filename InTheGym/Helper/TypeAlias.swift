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

typealias PostListener = PassthroughSubject<post,Never>

typealias GroupPostListener = PassthroughSubject<GroupPost,Never>
