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
    var childCoordinators = [Coordinator]()
    var navigationController: UINavigationController
    var userToShow: Users
    
    init(navigationController: UINavigationController, user: Users) {
        self.navigationController = navigationController
        self.userToShow = user
    }
    
    func start() {
        let vc = PublicTimelineViewController()
        vc.coordinator = self
        vc.viewModel.user = userToShow
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
        let child = PublicCreatedWorkoutsCoordinator(navigationController: navigationController, user: user)
        childCoordinators.append(child)
        child.start()
    }
    
    func showCommentSection(for post: post, with listener: PostListener) {
        let child = CommentSectionCoordinator(navigationController: navigationController, mainPost: post, listener: listener)
        childCoordinators.append(child)
        child.start()
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
    func showUser(user: Users) {
        let child = UserProfileCoordinator(navigationController: navigationController, user: user)
        childCoordinators.append(child)
        child.start()
    }
}


//MARK: - Child Coordinators Methods
extension UserProfileCoordinator {
    
    func showWorkout(workout: WorkoutDelegate) {
        let child = WorkoutCoordinator(navigationController: navigationController, workout: workout)
        childCoordinators.append(child)
        child.start()
    }
}

// MARK: - Show Clip
extension UserProfileCoordinator {
    func clipSelected(_  model: ClipModel) {
        let keyModel = KeyClipModel(clipKey: model.id, storageURL: model.storageURL)
        let vc = ViewClipViewController()
        vc.viewModel.keyClipModel = keyModel
        vc.modalPresentationStyle = .custom
        vc.transitioningDelegate = self
        navigationController.present(vc, animated: true)
    }
}

// MARK: - Custom Clip Picker
extension UserProfileCoordinator: UIViewControllerTransitioningDelegate {

    func presentationController(forPresented presented: UIViewController, presenting: UIViewController?, source: UIViewController) -> UIPresentationController? {
        let controller = BottomViewPresentationController(presentedViewController: presented, presenting: presenting)
        controller.viewHeightPrecentage = 1
        return controller
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
        
        if let WorkoutViewController = fromViewController as? DisplayWorkoutViewController {
            childDidFinish(WorkoutViewController.coordinator)
        }
        
        if let createdWorkoutsViewController = fromViewController as? PublicCreatedWorkoutsViewController {
            childDidFinish(createdWorkoutsViewController.coordinator)
        }
        
    }
}
