//
//  GroupWorkoutsProtocol.swift
//  InTheGym
//
//  Created by Findlay Wood on 18/08/2021.
//  Copyright © 2021 FindlayWood. All rights reserved.
//

import Foundation

protocol GroupWorkoutsProtocol {
    func getData(at indexPath: IndexPath) -> GroupWorkoutModel
    func numberOfWorkouts() -> Int
    func workoutSelected(at indexPath: IndexPath)
}
