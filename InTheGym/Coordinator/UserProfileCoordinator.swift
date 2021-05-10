//
//  UserProfileCoordinator.swift
//  InTheGym
//
//  Created by Findlay Wood on 06/05/2021.
//  Copyright © 2021 FindlayWood. All rights reserved.
//

import UIKit

/// Child Coordinator to handle the flow when a user profile is shown
class UserProfileCoordinator: NSObject, Coordinator {
    weak var parentCoordinator: TimelineCoordinator?
    var childCoordinators = [Coordinator]()
    var navigationController: UINavigationController
    var userToShow: Users
    
    init(navigationController: UINavigationController, user: Users) {
        self.navigationController = navigationController
        self.userToShow = user
    }
    
    func start() {
        let vc = PublicTimelineViewController.instantiate()
        vc.coordinator = self
        vc.user = userToShow
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
extension UserProfileCoordinator {
    
    func showCreatedWorkouts(for user: Users){
        let vc = PublicCreatedWorkoutsViewController.instantiate()
        vc.user = user
        navigationController.pushViewController(vc, animated: true)
    }
}


//MARK: - Child Coordinators Methods
extension UserProfileCoordinator {
    
    func showDiscussion(with post: PostProtocol, isGroup: Bool) {
        let child = DiscussionCoordinator(navigationController: navigationController, post: post, isGroup: isGroup)
        childCoordinators.append(child)
        child.start()
    }
    
    func showWorkout(workout: WorkoutDelegate) {
        let child = WorkoutCoordinator(navigationController: navigationController, workout: workout)
        childCoordinators.append(child)
        child.start()
    }
}


//MARK: - Navigation Controller Delegate Methods
extension UserProfileCoordinator: UINavigationControllerDelegate {
    func navigationController(_ navigationController: UINavigationController, didShow viewController: UIViewController, animated: Bool) {
        guard let fromViewController = navigationController.transitionCoordinator?.viewController(forKey: .from) else {
            return
        }
        
        if navigationController.viewControllers.contains(fromViewController){
            return
        }
        
        if let DiscusionViewController = fromViewController as? DiscussionViewViewController {
            childDidFinish(DiscusionViewController.coordinator)
        }
        
        if let WorkoutViewController = fromViewController as? DisplayWorkoutViewController {
            childDidFinish(WorkoutViewController.coordinator)
        }
        
    }
}
