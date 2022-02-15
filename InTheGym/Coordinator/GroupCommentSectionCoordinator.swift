//
//  GroupCommentSectionCoordinator.swift
//  InTheGym
//
//  Created by Findlay Wood on 14/02/2022.
//  Copyright © 2022 FindlayWood. All rights reserved.
//

import Foundation
import UIKit
import Combine

class GroupCommentSectionCoordinator: NSObject, Coordinator {
    var childCoordinators = [Coordinator]()
    var navigationController: UINavigationController
    var mainPost: GroupPost
    var savedWorkoutSelected = PassthroughSubject<SavedWorkoutModel,Never>()
    
    init(navigationController: UINavigationController, mainPost: GroupPost) {
        self.navigationController = navigationController
        self.mainPost = mainPost
    }
    
    func start() {
        let vc = GroupCommentSectionViewController()
        vc.coordinator = self
        vc.viewModel.mainGroupPost = mainPost
        navigationController.pushViewController(vc, animated: true)
    }
}

extension GroupCommentSectionCoordinator {
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
extension GroupCommentSectionCoordinator: SavedWorkoutsFlow {
    func savedWorkoutSelected(_ selectedWorkout: SavedWorkoutModel) {
        savedWorkoutSelected.send(selectedWorkout)
        navigationController.dismiss(animated: true)
    }
}
// MARK: - Custom Clip Picker
extension GroupCommentSectionCoordinator: UIViewControllerTransitioningDelegate {
    
    func presentationController(forPresented presented: UIViewController, presenting: UIViewController?, source: UIViewController) -> UIPresentationController? {
        let controller = BottomViewPresentationController(presentedViewController: presented, presenting: presenting)
        controller.viewHeightPrecentage = 0.8
        return controller
    }
}
