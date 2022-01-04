//
//  GroupHomeCoordinator.swift
//  InTheGym
//
//  Created by Findlay Wood on 06/08/2021.
//  Copyright © 2021 FindlayWood. All rights reserved.
//

import Foundation
import UIKit

class GroupHomeCoordinator: NSObject, Coordinator {
    var childCoordinators = [Coordinator]()
    var navigationController: UINavigationController
    var group: groupModel
    
    init(navigationController: UINavigationController, group: groupModel) {
        self.navigationController = navigationController
        self.group = group
    }
    
    func start() {
        navigationController.delegate = self
        let vc = GroupHomePageViewController()
        vc.coordinator = self
        vc.currentGroup = group
        vc.hidesBottomBarWhenPushed = true
        navigationController.pushViewController(vc, animated: true)
    }
}

// MARK: - Group Flow
extension GroupHomeCoordinator {
    func showMoreInfo(with info: MoreGroupInfoModel, _ delegate: GroupHomePageProtocol) {
        let vc = MoreGroupInfoViewController()
        vc.moreGroupInfo = info
        vc.delegate = delegate
        navigationController.present(vc, animated: true, completion: nil)
    }
    func goToGroupWorkouts(with info: groupModel) {
        let child = GroupWorkoutsCoordinator(navigationController: navigationController, group: info)
        childCoordinators.append(child)
        child.start()
    }
    func createNewPost() {
        let child = CreateNewPostCoordinator(navigationController: navigationController, assignee: group)
        childCoordinators.append(child)
        child.start()
    }
    func goToCommentSection(with mainPost: GroupPost) {
        let vc = GroupCommentSectionViewController()
        vc.mainPost = mainPost
        navigationController.pushViewController(vc, animated: true)
    }
}

//MARK: TimelineFlow Methods
extension GroupHomeCoordinator: TimelineFlow {
    
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
        
        if let DiscussionViewController = fromViewController as? DiscussionViewViewController {
            childDidFinish(DiscussionViewController.coordinator)
        }
        
        if let WorkoutViewController = fromViewController as? DisplayWorkoutViewController {
            childDidFinish(WorkoutViewController.coordinator)
        }
        if let GroupWorkoutController = fromViewController as? GroupWorkoutsViewController {
            childDidFinish(GroupWorkoutController.coordinator)
        }
    }
}

