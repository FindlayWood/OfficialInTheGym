//
//  File.swift
//  
//
//  Created by Findlay-Personal on 28/04/2023.
//

import Combine
import UIKit

class CreationCoordinator: CreationFlow {
    
    typealias FactoryType = Factory & ViewModelFactory
    
    var factory: FactoryType
    
    init(factory: FactoryType) {
        self.factory = factory
    }
    
    func start() {
        let vc = WorkoutCreationHomeViewController()
        vc.viewModel = factory.makeWorkoutCreationViewModel()
        vc.viewModel.coordinator = self
        vc.hidesBottomBarWhenPushed = true
        factory.navigationController.pushViewController(vc, animated: true)
    }
    
    func addNewExercise(_ workoutCreation: WorkoutCreation) {
        let vc = ExerciseCreationHomeViewController()
        vc.viewModel = ExerciseCreationHomeViewModel(workoutCreation: workoutCreation)
        vc.viewModel.coordinator = self
        factory.navigationController.pushViewController(vc, animated: true)
    }
    func popBack() {
        factory.navigationController.popViewController(animated: true)
    }
}

protocol CreationFlow: Coordinator {
    func addNewExercise(_ workoutCreation: WorkoutCreation)
    func popBack()
}
