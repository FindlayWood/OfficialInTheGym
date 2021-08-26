//
//  WorkoutsCoordinator.swift
//  InTheGym
//
//  Created by Findlay Wood on 05/05/2021.
//  Copyright © 2021 FindlayWood. All rights reserved.
//

import Foundation
import UIKit

protocol WorkoutsFlow {
    func showWorkout(workout: WorkoutDelegate)
    func addNewWorkout()
    func regularWorkout(_ assignee: Assignable)
    func addLiveWorkout()
    func startLiveWorkout(_ model: liveWorkout)
}

class WorkoutsCoordinator: NSObject, Coordinator {
    var childCoordinators = [Coordinator]()
    var navigationController: UINavigationController
    
    init(navigationController: UINavigationController) {
        self.navigationController = navigationController
        self.navigationController.navigationBar.setBackgroundImage(UIImage(), for: .default)
        self.navigationController.navigationBar.shadowImage = UIImage()
        self.navigationController.navigationBar.tintColor = .white
    }
    
    func start() {
        let vc = PlayerWorkoutViewController.instantiate()
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
extension WorkoutsCoordinator: WorkoutsFlow {
    func showWorkout(workout: WorkoutDelegate) {
        let child = WorkoutCoordinator(navigationController: navigationController, workout: workout)
        childCoordinators.append(child)
        child.start()
    }
    
    func addNewWorkout() {
        let vc = AddWorkoutSelectionViewController.instantiate()
        vc.coordinator = self
        navigationController.pushViewController(vc, animated: true)
    }
    
    func regularWorkout(_ assignee: Assignable) {
        let child = RegularWorkoutCoordinator(navigationController: navigationController, assignTo: assignee)
        childCoordinators.append(child)
        child.start()
    }
    
    func addLiveWorkout() {
        let vc = PreLiveWorkoutViewController.instantiate()
        vc.coordinator = self
        navigationController.pushViewController(vc, animated: true)
    }
    
    func startLiveWorkout(_ model: liveWorkout) {
        let child = LiveWorkoutCoordinator(navigationController: navigationController, model: model)
        childCoordinators.append(child)
        child.start()
    }
    
}


//MARK: - Child Coordinators
extension WorkoutsCoordinator {
    
}


//MARK: - Navigation Delegate Method
extension WorkoutsCoordinator: UINavigationControllerDelegate {
    
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
        
        if let DiscussionViewController = fromViewController as? DiscussionViewViewController {
            childDidFinish(DiscussionViewController.coordinator)
        }
        
        if let WorkoutViewController = fromViewController as? DisplayWorkoutViewController {
            childDidFinish(WorkoutViewController.coordinator)
        }
    }
}
