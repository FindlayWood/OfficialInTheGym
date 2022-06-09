//
//  AddWorkoutTagsNavigationModel.swift
//  InTheGym
//
//  Created by Findlay Wood on 07/06/2022.
//  Copyright © 2022 FindlayWood. All rights reserved.
//

import Foundation
import Combine

/// navigation model needed to coordinate to AddWorkoutTagsViewController
struct AddWorkoutTagsNavigationModel {
    var currentTags: [ExerciseTagReturnModel]
    var addedNewTagPublisher: PassthroughSubject<ExerciseTagReturnModel,Never>
}
