//
//  GroupHomeCoordinator.swift
//  InTheGym
//
//  Created by Findlay Wood on 06/08/2021.
//  Copyright © 2021 FindlayWood. All rights reserved.
//

import Foundation
import UIKit
import Combine

class GroupHomeCoordinator: NSObject, Coordinator {
    var childCoordinators = [Coordinator]()
    var navigationController: UINavigationController
    var group: GroupModel
    
    init(navigationController: UINavigationController, group: GroupModel) {
        self.navigationController = navigationController
        self.group = group
    }
    
    func start() {
        navigationController.delegate = self
        let vc = GroupHomePageViewController()
        vc.coordinator = self
        vc.viewModel.currentGroup = group
        vc.hidesBottomBarWhenPushed = true
        navigationController.pushViewController(vc, animated: true)
    }
}

// MARK: - Group Flow
extension GroupHomeCoordinator {
    func showMoreInfo(with model: GroupModel, listener: PassthroughSubject<(GroupModel,UIImage?),Never>) {
        let vc = MoreGroupInfoViewController()
        vc.viewModel.groupModel = model
        vc.viewModel.updatedGroup = listener
        navigationController.present(vc, animated: true, completion: nil)
    }
    func goToGroupWorkouts(with info: GroupModel) {
        let child = GroupWorkoutsCoordinator(navigationController: navigationController, group: info)
        childCoordinators.append(child)
        child.start()
    }
    func createNewPost(_ postable: Postable, listener: NewPostListener?) {
        let child = CreateNewPostCoordinator(navigationController: navigationController, postable: postable, listener: listener)
        childCoordinators.append(child)
        child.start()
    }
    func goToCommentSection(with mainPost: GroupPost) {
        let child = GroupCommentSectionCoordinator(navigationController: navigationController, mainPost: mainPost)
        childCoordinators.append(child)
        child.start()
//        let vc = GroupCommentSectionViewController()
//        vc.mainPost = mainPost
//        navigationController.pushViewController(vc, animated: true)
    }
    
    func showUser(user: Users) {
        let child = UserProfileCoordinator(navigationController: navigationController, user: user)
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
    
    func showMembers(_ group: GroupModel) {
        let vc = GroupMembersViewController()
        vc.coordinator = self
        vc.viewModel.group = group
        navigationController.pushViewController(vc, animated: true)
    }
}

//MARK: TimelineFlow Methods
//extension GroupHomeCoordinator: TimelineFlow {
//
//    func showWorkouts(with workout: WorkoutDelegate) {
//        let child = WorkoutCoordinator(navigationController: navigationController, workout: workout)
//        childCoordinators.append(child)
//        child.start()
//    }
//
//    func showUser(user: Users) {
//        let child = UserProfileCoordinator(navigationController: navigationController, user: user)
//        childCoordinators.append(child)
//        child.start()
//    }
//}

//MARK: - Navigation Delegate Method
extension GroupHomeCoordinator: UINavigationControllerDelegate {
    
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
        if let GroupWorkoutController = fromViewController as? GroupWorkoutsViewController {
            childDidFinish(GroupWorkoutController.coordinator)
        }
    }
}

