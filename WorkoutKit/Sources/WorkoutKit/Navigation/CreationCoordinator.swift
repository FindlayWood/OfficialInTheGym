//
//  File.swift
//  
//
//  Created by Findlay-Personal on 28/04/2023.
//

import Combine
import UIKit

class CreationCoordinator {
    
    var navigationController: UINavigationController
    var addNewWorkoutPublisher: AddNewWorkoutPublisher
    
    init(navigationController: UINavigationController, addNewWorkoutPublisher: AddNewWorkoutPublisher) {
        self.navigationController = navigationController
        self.addNewWorkoutPublisher = addNewWorkoutPublisher
    }
    
    func start() {
        let vc = WorkoutCreationHomeViewController()
        vc.viewModel = .init()
        vc.viewModel.coordinator = self
        vc.viewModel.addNewWorkoutPublisher = addNewWorkoutPublisher
        vc.hidesBottomBarWhenPushed = true
        navigationController.pushViewController(vc, animated: true)
    }
    
    func addNewExercise(_ viewModel: WorkoutCreationHomeViewModel) {
        let vc = ExerciseCreationHomeViewController()
        vc.viewModel = ExerciseCreationHomeViewModel(workoutViewModel: viewModel)
        vc.viewModel.coordinator = self
        navigationController.pushViewController(vc, animated: true)
    }
    func popBack() {
        navigationController.popViewController(animated: true)
    }
}
