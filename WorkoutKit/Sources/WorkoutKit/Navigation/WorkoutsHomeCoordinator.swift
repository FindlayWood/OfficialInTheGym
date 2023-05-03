//
//  File.swift
//  
//
//  Created by Findlay-Personal on 29/04/2023.
//

import UIKit

class WorkoutsHomeCoordinator {
    
    var navigationController: UINavigationController
    var apiService: NetworkService
    var currentUserService: CurrentUserServiceWorkoutKit
    
    init(navigationController: UINavigationController, apiService: NetworkService, userService: CurrentUserServiceWorkoutKit) {
        self.navigationController = navigationController
        self.apiService = apiService
        self.currentUserService = userService
    }
    
    func start() {
        let vc = WorkoutsHomeViewController()
        vc.viewModel = .init(apiService: apiService, userService: currentUserService)
        vc.viewModel.coordinator = self
        navigationController.pushViewController(vc, animated: true)
    }
    
    func addNewWorkout(publisher: AddNewWorkoutPublisher) {
        let childCooridnator = CreationCoordinator(navigationController: navigationController, addNewWorkoutPublisher: publisher, apiService: apiService, userService: currentUserService)
        childCooridnator.start()
    }
    
    func showWorkout(_ workout: WorkoutModel, exercises: [ExerciseModel]) {
        let child = DisplayCoordinator(navigationController: navigationController, workout: workout, exercises: exercises)
        child.start()
    }
}
