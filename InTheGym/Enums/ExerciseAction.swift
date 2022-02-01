//
//  ExerciseAction.swift
//  InTheGym
//
//  Created by Findlay Wood on 28/01/2022.
//  Copyright © 2022 FindlayWood. All rights reserved.
//

import Foundation

enum ExerciseAction {
    case noteButton
    case rpeButton
    case clipButton
    case exerciseButton
    case completed(IndexPath)
}

enum LiveExerciseAction {
    case noteButton
    case rpeButton
    case clipButton
    case exerciseButton
    //case completed(IndexPath)
    case addSet
}
