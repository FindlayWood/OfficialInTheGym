//
//  DisplayAMRAPProtocol.swift
//  InTheGym
//
//  Created by Findlay Wood on 08/06/2021.
//  Copyright © 2021 FindlayWood. All rights reserved.
//

import Foundation

protocol DisplayAMRAPProtocol {
    func getExercise(at indexPath: IndexPath) -> ExerciseModel
    func numberOfExercises() -> Int
}
