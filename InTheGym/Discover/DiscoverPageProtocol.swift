//
//  DiscoverPageProtocol.swift
//  InTheGym
//
//  Created by Findlay Wood on 15/04/2021.
//  Copyright © 2021 FindlayWood. All rights reserved.
//

import Foundation

protocol DiscoverPageProtocol {
    func getWorkout(at indexPath: IndexPath) -> discoverWorkout
    func getWOD() -> discoverWorkout
    func retreiveNumberOfWorkouts() -> Int
    func retrieveWOD() -> Bool
    func workoutSelected(at indexPath: IndexPath)
}
