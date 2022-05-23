//
//  NotificationsCoordinator.swift
//  InTheGym
//
//  Created by Findlay Wood on 06/08/2021.
//  Copyright © 2021 FindlayWood. All rights reserved.
//

import Foundation
import UIKit

class NotificationsCoordinator: NSObject, Coordinator {
    var childCoordinators = [Coordinator]()
    var navigationController: UINavigationController
    init(navigationController: UINavigationController) {
        self.navigationController = navigationController
    }
    
    func start() {
        navigationController.delegate = self
        let vc = DisplayNotificationsViewController()
        vc.coordinator = self
        navigationController.pushViewController(vc, animated: true)
    }
}

//MARK: TimelineFlow Methods
extension NotificationsCoordinator {
    
    
    func showUser(user: Users) {
        let child = UserProfileCoordinator(navigationController: navigationController, user: user)
        childCoordinators.append(child)
        child.start()
    }
    
    func showPost(post: PostModel) {
        let child = CommentSectionCoordinator(navigationController: navigationController, mainPost: post, listener: nil)
        childCoordinators.append(child)
        child.start()
    }
    
    func showGroupPost(post: GroupPost) {
        let child = GroupCommentSectionCoordinator(navigationController: navigationController, mainPost: post)
        childCoordinators.append(child)
        child.start()
    }
    
    func showPlayerDetail(player: Users) {
        let child = PlayerDetailCoordinator(navigationController: navigationController, player: player)
        childCoordinators.append(child)
        child.start()
    }
    
    func showRequests() {
        let vc = RequestsViewController()
        navigationController.pushViewController(vc, animated: true)
    }
    
}

//MARK: - Navigation Delegate Method
extension NotificationsCoordinator: UINavigationControllerDelegate {
    
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
    }
}
