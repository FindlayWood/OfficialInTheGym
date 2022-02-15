//
//  TimelineCoordinator.swift
//  InTheGym
//
//  Created by Findlay Wood on 05/05/2021.
//  Copyright © 2021 FindlayWood. All rights reserved.
//

import Foundation
import UIKit

protocol TimelineFlow: AnyObject {
    func showDiscussion(with post: PostProtocol, group: groupModel?)
    func showWorkouts(with workout: WorkoutDelegate)
    func showUser(user: Users)
}


protocol NewsFeedFlow: TimelineFlow {
    func makePost(groupPost: Bool, delegate: PlayerTimelineProtocol)
    func showCommentSection(for post: post)
}

class TimelineCoordinator: NSObject, Coordinator {
    
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
        let playerTimeline = PlayerTimelineViewController.instantiate()
        playerTimeline.coordinator = self
        navigationController.pushViewController(playerTimeline, animated: false)
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
extension TimelineCoordinator: NewsFeedFlow {
    
    func makePost(groupPost: Bool, delegate: PlayerTimelineProtocol) {
        let vc = MakePostViewController.instantiate()
        vc.groupBool = groupPost
        vc.timelineDelegate = delegate
        vc.modalTransitionStyle = .coverVertical
        vc.modalPresentationStyle = .fullScreen
        navigationController.present(vc, animated: true, completion: nil)
    }
    
    func showCommentSection(for post: post) {
        let child = CommentSectionCoordinator(navigationController: navigationController, mainPost: post)
        childCoordinators.append(child)
        child.start()
    }
}


//MARK: - Child Coordinators
extension TimelineCoordinator: TimelineFlow {
    
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
        child.parentCoordinator = self
        childCoordinators.append(child)
        child.start()
        
    }
}

//MARK: - Navigation Delegate Method
extension TimelineCoordinator: UINavigationControllerDelegate {
    
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
        
        if let CommentSectionViewController = fromViewController as? CommentSectionViewController {
            childDidFinish(CommentSectionViewController.coordinator)
        }
    }
}
