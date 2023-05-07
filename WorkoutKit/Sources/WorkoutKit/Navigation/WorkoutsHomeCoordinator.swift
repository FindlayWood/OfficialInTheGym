//
//  File.swift
//  
//
//  Created by Findlay-Personal on 29/04/2023.
//

import UIKit

class WorkoutsHomeCoordinator: WorkoutsHomeFlow {
    
    typealias Factory = HomeFactory & ViewModelFactory
    
    var factory: Factory
    
    init(factory: Factory) {
        self.factory = factory
    }
    
    func start() {
        let vc = WorkoutsHomeViewController()
        vc.viewModel = factory.makeWorkoutHomeViewModel()
        vc.viewModel.coordinator = self
        factory.navigationController.pushViewController(vc, animated: true)
    }
    
    func addNewWorkout() {
        let child = factory.makeWorkoutCreationCoordinator()
        child.start()
    }
    
    func showWorkout(_ workout: RemoteWorkoutModel) {
        let child = factory.makeDiplayWorkoutCoordinator(workout: workout)
        child.start()
    }
}

protocol Coordinator {
//    var navigationController: UINavigationController { get }
    func start()
}

protocol WorkoutsHomeFlow: Coordinator {
    func addNewWorkout()
    func showWorkout(_ workout: RemoteWorkoutModel)
}
