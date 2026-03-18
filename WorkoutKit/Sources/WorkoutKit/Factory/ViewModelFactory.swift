//
//  File.swift
//  
//
//  Created by Findlay-Personal on 08/05/2023.
//

import Foundation

protocol ViewModelFactory {
    func makeWorkoutHomeViewModel() -> WorkoutsHomeViewModel
    func makeWorkoutDisplayViewModel(with workout: RemoteWorkoutModel) -> WorkoutDisplayViewModel
    func makeWorkoutCreationViewModel() -> WorkoutCreationHomeViewModel
}

extension Factory: ViewModelFactory {
    func makeWorkoutHomeViewModel() -> WorkoutsHomeViewModel {
        return WorkoutsHomeViewModel(workoutManager: workoutManager)
    }
    func makeWorkoutDisplayViewModel(with workout: RemoteWorkoutModel) -> WorkoutDisplayViewModel {
        return WorkoutDisplayViewModel(workoutManager: workoutManager, workoutModel: workout, networkService: networkService)
    }
    func makeWorkoutCreationViewModel() -> WorkoutCreationHomeViewModel {
        return WorkoutCreationHomeViewModel(workoutManager: workoutManager, factory: self)
    }
}
