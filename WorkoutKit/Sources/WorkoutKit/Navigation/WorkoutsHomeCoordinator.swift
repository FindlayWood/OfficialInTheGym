//
//  File.swift
//  
//
//  Created by Findlay-Personal on 29/04/2023.
//

import UIKit

class WorkoutsHomeCoordinator {
    
    var navigationController: UINavigationController
    
    init(navigationController: UINavigationController) {
        self.navigationController = navigationController
    }
    
    func start() {
        let vc = WorkoutsHomeViewController()
        vc.viewModel = .init()
        vc.viewModel.coordinator = self
        navigationController.pushViewController(vc, animated: true)
    }
    
    func addNewWorkout(publisher: AddNewWorkoutPublisher) {
        let childCooridnator = CreationCoordinator(navigationController: navigationController, addNewWorkoutPublisher: publisher)
        childCooridnator.start()
    }
    
    func showWorkout(_ workout: WorkoutModel, exercises: [ExerciseModel]) {
        let child = DisplayCoordinator(navigationController: navigationController, workout: workout, exercises: exercises)
        child.start()
    }
}
