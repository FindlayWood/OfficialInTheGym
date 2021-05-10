//
//  DiscoverCoordinator.swift
//  InTheGym
//
//  Created by Findlay Wood on 05/05/2021.
//  Copyright © 2021 FindlayWood. All rights reserved.
//

import Foundation
import UIKit

protocol DiscoverFlow {
    func wodSelected(workout: WorkoutDelegate)
    func workoutSelected(workout: WorkoutDelegate)
    func search()
}

class DiscoverCoordinator: NSObject, Coordinator {

    var childCoordinators = [Coordinator]()
    var navigationController: UINavigationController
    
    init(navigationController: UINavigationController){
        self.navigationController = navigationController
        self.navigationController.navigationBar.setBackgroundImage(UIImage(), for: .default)
        self.navigationController.navigationBar.shadowImage = UIImage()
        self.navigationController.navigationBar.tintColor = .white
    }
    
    func start() {
        let vc = DiscoverPageViewController.instantiate()
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
extension DiscoverCoordinator: DiscoverFlow {
    
    func wodSelected(workout: WorkoutDelegate) {
        let child = WorkoutCoordinator(navigationController: navigationController, workout: workout)
        childCoordinators.append(child)
        child.start()
    }
    
    /// add child coordinator, push new navigation controller and have child coordinator take control of navigation
    func workoutSelected(workout: WorkoutDelegate) {
        let child = WorkoutCoordinator(navigationController: navigationController, workout: workout)
        childCoordinators.append(child)
        child.start()
    }
    
    func search() {
        let vc = SearchForUsersViewController.instantiate()
        navigationController.pushViewController(vc, animated: true)
    }
}

//MARK: - Navigation Delegate Method
extension DiscoverCoordinator: UINavigationControllerDelegate {
    
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
        
//        if let DiscussionViewController = fromViewController as? DiscussionViewViewController {
//            childDidFinish(DiscussionViewController.coordinator)
//        }
        
        if let WorkoutViewController = fromViewController as? DisplayWorkoutViewController {
            childDidFinish(WorkoutViewController.coordinator)
        }
    }
}
