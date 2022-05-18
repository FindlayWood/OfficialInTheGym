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
    var mainPost: PostModel
    var savedWorkoutSelected = PassthroughSubject<SavedWorkoutModel,Never>()
    var listener: PostListener?
    
    init(navigationController: UINavigationController, mainPost: PostModel, listener: PostListener?) {
        self.navigationController = navigationController
        self.mainPost = mainPost
        self.listener = listener
    }
    
    func start() {
        navigationController.delegate = self
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
        let child = WorkoutDisplayCoordinator(navigationController: navigationController, workout: workout)
        childCoordinators.append(child)
        child.start()
    }
    func showSavedWorkout(_ model: SavedWorkoutModel) {
        let child = SavedWorkoutCoordinator(navigationController: navigationController, savedWorkoutModel: model)
        childCoordinators.append(child)
        child.start()
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
    func savedWorkoutSelected(_ selectedWorkout: SavedWorkoutModel, listener: SavedWorkoutRemoveListener?) {
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

extension CommentSectionCoordinator: UINavigationControllerDelegate {
    
}
