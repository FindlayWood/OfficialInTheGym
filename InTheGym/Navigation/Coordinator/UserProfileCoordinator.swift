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
    var subscriptionManager: PurchaseManager
    
    init(navigationController: UINavigationController, user: Users, subscriptionManager: PurchaseManager) {
        self.navigationController = navigationController
        self.userToShow = user
        self.subscriptionManager = subscriptionManager
    }
    
    func start() {
        let vc = PublicTimelineViewController()
        vc.coordinator = self
        vc.purchaseManager = subscriptionManager
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
    func showCommentSection(for post: PostModel, with listener: PostListener) {
        let child = CommentSectionCoordinator(navigationController: navigationController, mainPost: post, listener: listener, deleteListener: nil, subscriptionManager: subscriptionManager)
        childCoordinators.append(child)
        child.start()
    }
    func showWorkout(_ model: WorkoutModel) {
        let child = WorkoutDisplayCoordinator(navigationController: navigationController, workout: model, subscriptionManager: subscriptionManager)
        childCoordinators.append(child)
        child.start()
    }
    func showSavedWorkout(_ model: SavedWorkoutModel) {
        let child = SavedWorkoutCoordinator(navigationController: navigationController, savedWorkoutModel: model, subscriptionManager: subscriptionManager)
        childCoordinators.append(child)
        child.start()
    }
    func showStampsPreview() {
        let vc = StampsPreviewViewController()
        navigationController.present(vc, animated: true)
    }
    func showUser(user: Users) {
        let child = UserProfileCoordinator(navigationController: navigationController, user: user, subscriptionManager: subscriptionManager)
        childCoordinators.append(child)
        child.start()
    }
    func showUserClips(user: Users) {
        let vc = PublicClipsViewController()
        vc.viewModel.user = user
        vc.coordinator = self
        vc.hidesBottomBarWhenPushed = true
        navigationController.pushViewController(vc, animated: true)
    }
    func showUserWorkouts(user: Users) {
        let vc = PublicWorkoutsViewController()
        vc.viewModel.user = user
        vc.coordinator = self
        vc.hidesBottomBarWhenPushed = true
        navigationController.pushViewController(vc, animated: true)
    }
    func showUserFollowers(user: Users) {
        let vc = PublicFollowersViewController()
        vc.viewModel.user = user
        vc.coordinator = self
        vc.hidesBottomBarWhenPushed = true
        navigationController.pushViewController(vc, animated: true)
    }
}


//MARK: - Child Coordinators Methods
extension UserProfileCoordinator {
    
}

// MARK: - Show Clip
extension UserProfileCoordinator {
    func clipSelected(_  model: ClipModel, fromViewControllerDelegate: CustomAnimatingClipFromVC) {
        let keyModel = KeyClipModel(clipKey: model.id, storageURL: model.storageURL)
        let child = ClipProfileCustomCoordinator(navigationController: navigationController, clipModel: keyModel, fromViewControllerDelegate: fromViewControllerDelegate, subscriptionManager: subscriptionManager)
        childCoordinators.append(child)
        child.start()
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
    }
}
