//
//  WorkoutCreationOptionsNavigationModel.swift
//  InTheGym
//
//  Created by Findlay Wood on 07/06/2022.
//  Copyright © 2022 FindlayWood. All rights reserved.
//

import Foundation
import Combine
/// navigation model needed to coordinate to WorkoutCreationOptionsViewController
struct WorkoutCreationOptionsNavigationModel {
    var isSaving: Bool
    var isPrivate: Bool
    var assignTo: Users?
    var currentTags: [ExerciseTagReturnModel]
    var toggledSaving: PassthroughSubject<Void,Never>
    var toggledPrivacy: PassthroughSubject<Void,Never>
    var addedNewTag: PassthroughSubject<ExerciseTagReturnModel,Never>
}
