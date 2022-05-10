//
//  WorkoutCreationFlows.swift
//  InTheGym
//
//  Created by Findlay Wood on 09/05/2022.
//  Copyright © 2022 FindlayWood. All rights reserved.
//

import Foundation

protocol ExerciseSelectionFlow: AnyObject {
    func exerciseSelected(_ exercise: ExerciseModel)
    func addCircuit()
    func addAmrap()
    func addEmom()
}
protocol SetSelectionFlow: AnyObject {
    func setSelected(_ exercise: ExerciseModel)
}
protocol RepSelectionFlow: AnyObject {
    func repsSelected(_ exercise: ExerciseModel)
}
protocol WeightSelectionFlow: AnyObject {
    func weightSelected(_ exercise: ExerciseModel)
}
protocol FinishedExerciseCreationFlow: AnyObject {
    func finishedExercise(_ exercise: ExerciseModel)
}
