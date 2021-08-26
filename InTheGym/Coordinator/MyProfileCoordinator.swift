//
//  MyProfileCoordinator.swift
//  InTheGym
//
//  Created by Findlay Wood on 05/05/2021.
//  Copyright © 2021 FindlayWood. All rights reserved.
//

import Foundation
import UIKit

protocol MyProfileFlow: TimelineFlow {
    func showGroups()
    func showNotifications()
    func showSavedWorkouts()
    func showCreatedWorkouts()
    func showScores()
    func editProfile(profileImage: UIImage?, profileBIO: String, delegate: MyProfileProtocol)
    func showMoreInfo()
    func showFollowers(_ followers: Bool)
}

class MyProfileCoordinator: NSObject, Coordinator {
    
    var childCoordinators = [Coordinator]()
    var navigationController: UINavigationController
    
    init(navigationController: UINavigationController){
        self.navigationController = navigationController
        self.navigationController.navigationBar.setBackgroundImage(UIImage(), for: .default)
        self.navigationController.navigationBar.shadowImage = UIImage()
        self.navigationController.navigationBar.tintColor = .white
    }
    
    func start() {
        navigationController.delegate = self
        let vc = MyProfileViewController.instantiate()
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
extension MyProfileCoordinator: MyProfileFlow {
    
    func showGroups() {
        let child = GroupCoordinator(navigationController: navigationController)
        childCoordinators.append(child)
        child.start()
    }
    
    func showNotifications() {
        let child = NotificationsCoordinator(navigationController: navigationController)
        childCoordinators.append(child)
        child.start()
    }
    
    func showSavedWorkouts() {
        let vc = SavedWorkoutsViewController.instantiate()
        vc.coordinator = self
        navigationController.pushViewController(vc, animated: true)
    }
    
    func showCreatedWorkouts() {
        let child = CreatedWorkoutsCoordinator(navigationController: navigationController)
        childCoordinators.append(child)
        child.start()
    
    }
    
    func showScores() {
        if ViewController.admin {
            let vc = CoachScoresViewController.instantiate()
            vc.hidesBottomBarWhenPushed = true
            navigationController.pushViewController(vc, animated: true)
            
        } else {
            let vc = MYSCORESViewController.instantiate()
            vc.hidesBottomBarWhenPushed = true
            navigationController.pushViewController(vc, animated: true)
        }
    }
    
    func editProfile(profileImage: UIImage?, profileBIO: String, delegate: MyProfileProtocol) {
        let vc = EditProfileViewController.instantiate()
        vc.theImage = profileImage
        vc.theText = profileBIO
        vc.delegate = delegate
        vc.modalTransitionStyle = .coverVertical
        vc.modalPresentationStyle = .fullScreen
        navigationController.present(vc, animated: true, completion: nil)
    }
    
    func showMoreInfo() {
        if ViewController.admin {
            let vc = CoachInfoViewController.instantiate()
            navigationController.pushViewController(vc, animated: true)
            
        } else {
            let vc = NewInfoViewController.instantiate()
            navigationController.pushViewController(vc, animated: true)
        }
    }
    
    func showFollowers(_ followers: Bool) {
        let vc = FollowersDisplayViewController.instantiate()
        vc.followers = followers
        navigationController.pushViewController(vc, animated: true)
    }
}

// MARK: - Saved WorkoutFlow
extension MyProfileCoordinator: SavedWorkoutsFlow {
    func savedWorkoutSelected(_ selectedWorkout: savedWorkoutDelegate) {
        let child = WorkoutCoordinator(navigationController: navigationController, workout: selectedWorkout)
        childCoordinators.append(child)
        child.start()
    }
}


//MARK: - Child Coordinators
extension MyProfileCoordinator: TimelineFlow {
    
    func showDiscussion(with post: PostProtocol, group: groupModel?) {
        let child = DiscussionCoordinator(navigationController: navigationController, post: post, group: group)
        childCoordinators.append(child)
        child.start()
    }
    
    func showWorkouts(with workout: WorkoutDelegate) {
        let child = WorkoutCoordinator(navigationController: navigationController, workout: workout)
        childCoordinators.append(child)
        child.start()
    }
    
    func showUser(user: Users) {
        let child = UserProfileCoordinator(navigationController: navigationController, user: user)
        childCoordinators.append(child)
        child.start()
    }
}


//MARK: - Navigation Delegate Method
extension MyProfileCoordinator: UINavigationControllerDelegate {
    
    func navigationController(_ navigationController: UINavigationController, didShow viewController: UIViewController, animated: Bool) {
        guard let fromViewController = navigationController.transitionCoordinator?.viewController(forKey: .from) else {
            return
        }
        
        if navigationController.viewControllers.contains(fromViewController){
            return
        }
        
        if let UserViewController = fromViewController as? PublicTimelineViewController {
            childDidFinish(UserViewController.coordinator)
        }
        
        if let DiscusionViewController = fromViewController as? DiscussionViewViewController {
            childDidFinish(DiscusionViewController.coordinator)
        }
        
        if let WorkoutViewController = fromViewController as? DisplayWorkoutViewController {
            childDidFinish(WorkoutViewController.coordinator)
        }
        
        if let GroupViewController = fromViewController as? MyGroupsViewController {
            childDidFinish(GroupViewController.coordinator)
        }
        
        if let NotificationsController = fromViewController as? DisplayNotificationsViewController {
            childDidFinish(NotificationsController.coordinator)
        }
    }
}
