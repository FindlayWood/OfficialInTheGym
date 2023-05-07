//
//  File.swift
//  
//
//  Created by Findlay-Personal on 30/04/2023.
//

import UIKit

class DisplayCoordinator: DisplayFlow {
    
    typealias Factory = HomeFactory & ViewModelFactory
    
    var factory: Factory
    var workout: RemoteWorkoutModel
    
    init(factory: Factory, workout: RemoteWorkoutModel) {
        self.factory = factory
        self.workout = workout
    }
    
    func start() {
        let vc = WorkoutDisplayViewController()
        vc.viewModel = factory.makeWorkoutDisplayViewModel(with: workout)
        vc.hidesBottomBarWhenPushed = true
        factory.navigationController.pushViewController(vc, animated: true)
    }
    
    func popBack() {
        factory.navigationController.popViewController(animated: true)
    }
}

protocol DisplayFlow: Coordinator {
    func popBack()
}
