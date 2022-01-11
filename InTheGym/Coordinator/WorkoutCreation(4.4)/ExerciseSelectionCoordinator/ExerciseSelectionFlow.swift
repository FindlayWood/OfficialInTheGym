//
//  ExerciseSelectionFlow.swift
//  InTheGym
//
//  Created by Findlay Wood on 06/01/2022.
//  Copyright © 2022 FindlayWood. All rights reserved.
//

import Foundation

protocol ExerciseSelectionFlow: AnyObject {
    func ciruit()
    func emom()
    func amrap()
    func exercise(viewModel: ExerciseCreationViewModel)
}
