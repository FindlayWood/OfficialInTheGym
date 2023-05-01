//
//  File.swift
//  
//
//  Created by Findlay-Personal on 30/04/2023.
//

import UIKit

class DisplayCoordinator {
    
    var navigationController: UINavigationController
    var workout: WorkoutModel
    var exerccises: [ExerciseModel]
    
    init(navigationController: UINavigationController, workout: WorkoutModel, exercises: [ExerciseModel]) {
        self.navigationController = navigationController
        self.workout = workout
        self.exerccises = exercises
    }
    
    func start() {
        let vc = WorkoutDisplayViewController()
        vc.viewModel = .init(workoutModel: workout, exercises: exerccises)
        vc.hidesBottomBarWhenPushed = true
        navigationController.pushViewController(vc, animated: true)
    }
    
    func popBack() {
        navigationController.popViewController(animated: true)
    }
}
