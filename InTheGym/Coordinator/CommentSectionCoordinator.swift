//
//  CommentSectionCoordinator.swift
//  InTheGym
//
//  Created by Findlay Wood on 16/01/2022.
//  Copyright © 2022 FindlayWood. All rights reserved.
//

import Foundation
import UIKit
import Combine

class CommentSectionCoordinator: NSObject, Coordinator {
    var childCoordinators = [Coordinator]()
    var navigationController: UINavigationController
    var mainPost: post
    var savedWorkoutSelected = PassthroughSubject<SavedWorkoutModel,Never>()
    var listener: PostListener
    
    init(navigationController: UINavigationController, mainPost: post, listener: PostListener) {
        self.navigationController = navigationController
        self.mainPost = mainPost
        self.listener = listener
    }
    
    func start() {
        let vc = CommentSectionViewController()
        vc.coordinator = self
        vc.viewModel.mainPost = mainPost
        vc.viewModel.listener = listener
        navigationController.pushViewController(vc, animated: true)
    }
}

extension CommentSectionCoordinator {
    func showUser(_ user: Users) {
        let child = UserProfileCoordinator(navigationController: navigationController, user: user)
        childCoordinators.append(child)
        child.start()
    }
    func showWorkout(_ workout: WorkoutModel) {
        
    }
    func attachWorkout() {
        let vc = SavedWorkoutsViewController()
        vc.coordinator = self
        vc.modalPresentationStyle = .custom
        vc.transitioningDelegate = self
        navigationController.present(vc, animated: true, completion: nil)
    }
}
extension CommentSectionCoordinator: SavedWorkoutsFlow {
    func savedWorkoutSelected(_ selectedWorkout: SavedWorkoutModel) {
        savedWorkoutSelected.send(selectedWorkout)
        navigationController.dismiss(animated: true)
    }
}
// MARK: - Custom Clip Picker
extension CommentSectionCoordinator: UIViewControllerTransitioningDelegate {
    
    func presentationController(forPresented presented: UIViewController, presenting: UIViewController?, source: UIViewController) -> UIPresentationController? {
        let controller = BottomViewPresentationController(presentedViewController: presented, presenting: presenting)
        controller.viewHeightPrecentage = 0.8
        return controller
    }
}
