//
//  CreatedWorkoutsCoordinator.swift
//  InTheGym
//
//  Created by Findlay Wood on 06/08/2021.
//  Copyright © 2021 FindlayWood. All rights reserved.
//

import Foundation
import UIKit

class PublicCreatedWorkoutsCoordinator: NSObject, Coordinator {
    var childCoordinators = [Coordinator]()
    var navigationController: UINavigationController
    var user: Users
    init(navigationController: UINavigationController, user: Users) {
        self.navigationController = navigationController
        self.user = user
    }
    func start() {
        navigationController.delegate = self
        let vc = PublicCreatedWorkoutsViewController.instantiate()
        vc.coordinator = self
        vc.user = user
        navigationController.pushViewController(vc, animated: true)
    }
}
//MARK: Flow Methods
extension PublicCreatedWorkoutsCoordinator {
    func showWorkout(workout: WorkoutDelegate) {
        let child = WorkoutCoordinator(navigationController: navigationController, workout: workout)
        childCoordinators.append(child)
        child.start()
    }
}

//MARK: - Navigation Delegate Method
extension PublicCreatedWorkoutsCoordinator: UINavigationControllerDelegate {
    
    func navigationController(_ navigationController: UINavigationController, didShow viewController: UIViewController, animated: Bool) {
        guard let fromViewController = navigationController.transitionCoordinator?.viewController(forKey: .from) else {
            return
        }
        
        if navigationController.viewControllers.contains(fromViewController){
            return
        }
        
        if let WorkoutViewController = fromViewController as? DisplayWorkoutViewController {
            childDidFinish(WorkoutViewController.coordinator)
        }
    }
}
