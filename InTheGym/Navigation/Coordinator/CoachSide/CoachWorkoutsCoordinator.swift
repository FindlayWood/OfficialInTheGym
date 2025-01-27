//
//  CoachWorkoutsCoordinator.swift
//  InTheGym
//
//  Created by Findlay Wood on 25/05/2022.
//  Copyright © 2022 FindlayWood. All rights reserved.
//

import Foundation
import UIKit

class CoachWorkoutsCoordinator: NSObject, Coordinator {
    var childCoordinators = [Coordinator]()
    var navigationController: UINavigationController
    var subscriptionManager: PurchaseManager
    
    init(navigationController: UINavigationController, subscriptionManager: PurchaseManager) {
        self.navigationController = navigationController
        self.subscriptionManager = subscriptionManager
    }
    
    func start() {
        let vc = CoachWorkoutsViewController()
        vc.coordinator = self
        navigationController.pushViewController(vc, animated: true)
    }
    
    func childDidFinish(_ child: Coordinator?) {
        for (index, coordinator) in childCoordinators.enumerated() {
            if coordinator === child {
                childCoordinators.remove(at: index)
                break
            }
        }
    }
}

//MARK: - Flow Methods
extension CoachWorkoutsCoordinator: WorkoutsFlow {

    func plusPressed() {
        let vc = NewWorkoutSelectionViewController()
        vc.coordinator = self
        navigationController.pushViewController(vc, animated: true)
    }
    func addNewWorkout(_ assignTo: Users?) {
        let child = RegularWorkoutCreationCoordinator(navigationController: navigationController, assignTo: assignTo, subscriptionManager: subscriptionManager)
        childCoordinators.append(child)
        child.start()
    }
    func addLiveWorkout() {
        let vc = PreLiveWorkoutViewController.instantiate()
        vc.coordinator = self
        navigationController.pushViewController(vc, animated: true)
    }
    func addSavedWorkout() {
        let child = RegularWorkoutCreationCoordinator(navigationController: navigationController, assignTo: nil, subscriptionManager: subscriptionManager)
        childCoordinators.append(child)
        child.start()
    }
}


//MARK: - Child Coordinators
extension CoachWorkoutsCoordinator: PreLiveWorkoutFlow {
    func show(_ workout: WorkoutModel) {
        let child = WorkoutDisplayCoordinator(navigationController: navigationController, workout: workout, subscriptionManager: subscriptionManager)
        childCoordinators.append(child)
        child.start()
    }
    func showLiveWorkout(_ workout: WorkoutModel) {
        let child = LiveWorkoutDisplayCoordinator(navigationController: navigationController, workout: workout, subscriptionManager: subscriptionManager)
        childCoordinators.append(child)
        child.start()
    }
}


//MARK: - Navigation Delegate Method
extension CoachWorkoutsCoordinator: UINavigationControllerDelegate {
    
    func navigationController(_ navigationController: UINavigationController, didShow viewController: UIViewController, animated: Bool) {
        guard let fromViewController = navigationController.transitionCoordinator?.viewController(forKey: .from) else {
            return
        }
        
        if navigationController.viewControllers.contains(fromViewController){
            return
        }
        
        if let PublicViewController = fromViewController as? PublicTimelineViewController {
            childDidFinish(PublicViewController.coordinator)
        }
    }
}
