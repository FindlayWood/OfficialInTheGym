//
//  ExerciseSelectionFlow.swift
//  InTheGym
//
//  Created by Findlay Wood on 06/01/2022.
//  Copyright © 2022 FindlayWood. All rights reserved.
//

import Foundation

protocol ExerciseSelectionFlow: AnyObject {
    func exercise(viewModel: ExerciseCreationViewModel)
}
protocol RegularExerciseSelectionFlow: ExerciseSelectionFlow {
    func circuit()
    func emom()
    func amrap()
}
