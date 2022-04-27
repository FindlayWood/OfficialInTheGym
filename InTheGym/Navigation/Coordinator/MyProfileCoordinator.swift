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
        let vc = MyProfileViewController()
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
extension MyProfileCoordinator {
    
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
        let vc = SavedWorkoutsViewController()
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
    
    func showMoreInfo() {
        if UserDefaults.currentUser.admin {
            let vc = CoachProfileMoreViewController()
            navigationController.pushViewController(vc, animated: true)
            
        } else {
            let vc = PlayerProfileMoreViewController()
            navigationController.pushViewController(vc, animated: true)
//            let vc = NewInfoViewController.instantiate()
//            navigationController.pushViewController(vc, animated: true)
        }
    }
    
    func showFollowers(_ followers: Bool) {
        let vc = FollowersDisplayViewController.instantiate()
        vc.followers = followers
        navigationController.pushViewController(vc, animated: true)
    }
    
    func showWorkout(_ model: WorkoutModel) {
        let child = WorkoutDisplayCoordinator(navigationController: navigationController, workout: model)
        childCoordinators.append(child)
        child.start()
    }
    func showSavedWorkout(_ model: SavedWorkoutModel) {
        let child = SavedWorkoutCoordinator(navigationController: navigationController, savedWorkoutModel: model)
        childCoordinators.append(child)
        child.start()
    }
    func showCommentSection(post: post, with listener: PostListener) {
        let child = CommentSectionCoordinator(navigationController: navigationController, mainPost: post, listener: listener)
        childCoordinators.append(child)
        child.start()
    }
}

// MARK: - Show Clip
extension MyProfileCoordinator {
    func clipSelected(_  model: ClipModel, fromViewControllerDelegate: CustomAnimatingClipFromVC) {
        let keyClipModel = KeyClipModel(clipKey: model.id, storageURL: model.storageURL)
        let child = ClipProfileCustomCoordinator(navigationController: navigationController, clipModel: keyClipModel, fromViewControllerDelegate: fromViewControllerDelegate)
        childCoordinators.append(child)
        child.start()
        
//        let keyModel = KeyClipModel(clipKey: model.id, storageURL: model.storageURL)
//        let vc = ViewClipViewController()
//        vc.viewModel.keyClipModel = keyModel
//        vc.modalPresentationStyle = .custom
//        vc.hidesBottomBarWhenPushed = true
////        vc.transitioningDelegate = self
//        navigationController.pushViewController(vc, animated: true)
    }
}

// MARK: - Custom Clip Picker
extension MyProfileCoordinator: UIViewControllerTransitioningDelegate {

    func presentationController(forPresented presented: UIViewController, presenting: UIViewController?, source: UIViewController) -> UIPresentationController? {
        let controller = BottomViewPresentationController(presentedViewController: presented, presenting: presenting)
        controller.viewHeightPrecentage = 1
        return controller
    }
}

// MARK: - Saved WorkoutFlow
extension MyProfileCoordinator: SavedWorkoutsFlow {
    func savedWorkoutSelected(_ selectedWorkout: SavedWorkoutModel, listener: SavedWorkoutRemoveListener?) {
        let child = SavedWorkoutCoordinator(navigationController: navigationController, savedWorkoutModel: selectedWorkout, listener: listener)
        childCoordinators.append(child)
        child.start()
//        let vc = SavedWorkoutDisplayViewController()
//        vc.viewModel.savedWorkout = selectedWorkout
//        vc.hidesBottomBarWhenPushed = true
//        navigationController.pushViewController(vc, animated: true)
//        let child = WorkoutCoordinator(navigationController: navigationController, workout: selectedWorkout)
//        childCoordinators.append(child)
//        child.start()
    }
}


//MARK: - Child Coordinators
extension MyProfileCoordinator: TimelineFlow {
    
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
