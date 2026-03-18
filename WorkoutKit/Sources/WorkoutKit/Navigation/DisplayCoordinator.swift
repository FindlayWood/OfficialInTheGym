//
//  File.swift
//  
//
//  Created by Findlay-Personal on 30/04/2023.
//

import UIKit

class DisplayCoordinator: DisplayFlow {
    
    typealias FactoryType = Factory & ViewModelFactory
    
    var factory: FactoryType
    var workout: RemoteWorkoutModel
    
    init(factory: FactoryType, workout: RemoteWorkoutModel) {
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
