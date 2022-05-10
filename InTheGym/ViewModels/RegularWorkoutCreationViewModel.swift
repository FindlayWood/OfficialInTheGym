//
//  RegularWorkoutCreationViewModel.swift
//  InTheGym
//
//  Created by Findlay Wood on 09/05/2022.
//  Copyright © 2022 FindlayWood. All rights reserved.
//

import Foundation
import Combine

class RegularCreationViewModel {
    @Published var exerciseCompleted: Bool = false
    var exercise: ExerciseModel!
}
