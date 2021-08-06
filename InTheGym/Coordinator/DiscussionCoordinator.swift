//
//  DiscussionCoordinator.swift
//  InTheGym
//
//  Created by Findlay Wood on 06/05/2021.
//  Copyright © 2021 FindlayWood. All rights reserved.
//

import Foundation
import UIKit

/// Child Coordinator to handle the flow when the discussion view controller appears
class DiscussionCoordinator: NSObject, Coordinator {
    var childCoordinators = [Coordinator]()
    var navigationController: UINavigationController
    
    var post: PostProtocol
    var group: groupModel?
    
    init(navigationController: UINavigationController, post: PostProtocol, group: groupModel?) {
        self.navigationController = navigationController
        self.post = post
        self.group = group
    }
    
    func start() {
        let vc = DiscussionViewViewController.instantiate()
        vc.coordinator = self
        vc.originalPost = post
        vc.group = group
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
extension DiscussionCoordinator {
    
    func addReply() {
        let vc = ReplyViewController.instantiate()
        vc.modalTransitionStyle = .coverVertical
        vc.modalPresentationStyle = .formSheet
        navigationController.present(vc, animated: true, completion: nil)
    }
}


//MARK: - Child Coordinator Methods
extension DiscussionCoordinator {
    
    func showUser(with user: Users) {
        let child = UserProfileCoordinator(navigationController: navigationController, user: user)
        childCoordinators.append(child)
        child.start()
    }
    
    func showWorkout(with workout: WorkoutDelegate) {
        let child = WorkoutCoordinator(navigationController: navigationController, workout: workout)
        childCoordinators.append(child)
        child.start()
    }
}


//MARK: - Navigation Delegate Methods
extension DiscussionCoordinator: UINavigationControllerDelegate {
    
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
        
        if let WorkoutViewController = fromViewController as? DisplayWorkoutViewController {
            childDidFinish(WorkoutViewController.coordinator)
        }
    }

}
