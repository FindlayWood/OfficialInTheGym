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
    var modalNavigationController: UINavigationController?
    var attachmentsModal: UINavigationController!
    private var userCompletionHandler: (Users) -> Void = { _ in }
    private var savedCompletionHandle: (SavedWorkoutModel) -> Void = { _ in }
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
    func attachWorkout(_ model: PostModel) {
        self.modalNavigationController = UINavigationController()
        let vc = CommentWithAttachmentsViewController()
        modalNavigationController?.setViewControllers([vc], animated: false)
        vc.coordinator = self
        if let modalNavigationController = modalNavigationController {
            modalNavigationController.modalPresentationStyle = .fullScreen
            navigationController.present(modalNavigationController, animated: true, completion: nil)
        }
        
//        let vc = SavedWorkoutsViewController()
//        vc.coordinator = self
//        vc.modalPresentationStyle = .custom
//        vc.transitioningDelegate = self
//        navigationController.present(vc, animated: true, completion: nil)
    }
    func attachmentSheet(_ viewModel: CommentSectionViewModel) {
        self.modalNavigationController = UINavigationController()
        let vc = CommentWithAttachmentsViewController()
        modalNavigationController?.setViewControllers([vc], animated: false)
        vc.coordinator = self
        vc.viewModel = viewModel
        if let modalNavigationController = modalNavigationController {
            modalNavigationController.modalPresentationStyle = .fullScreen
            navigationController.present(modalNavigationController, animated: true, completion: nil)
        }
    }
    func showAttachments(_ viewModel: CommentSectionViewModel) {
        guard let modalNavigationController else {return}
        let vc = CommentAttachmentSheetViewController()
        attachmentsModal = UINavigationController(rootViewController: vc)
        vc.viewModel = viewModel
        vc.coordinator = self
        modalNavigationController.present(attachmentsModal, animated: true, completion: nil)
    }
    func showSavedWorkoutPicker() {
        guard let modalNavigationController = modalNavigationController else {return}
        let vc = SavedWorkoutsViewController()
        vc.coordinator = self
        modalNavigationController.present(vc, animated: true, completion: nil)
    }
    func showUserSelection(completion: @escaping (Users) -> ()) {
        self.userCompletionHandler = completion
        let vc = SearchViewController()
        vc.coordinator = self
        let nav = UINavigationController(rootViewController: vc)
        attachmentsModal.present(nav, animated: true)
    }
    func showTaggedUsers(_ ids: [String]) {
        let child = TaggedUsersCoordinator(navigationController: navigationController, ids: ids)
        childCoordinators.append(child)
        child.start()
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

// MARK: - User Selection
extension CommentSectionCoordinator: UserSearchFlow {
    func userSelected(_ user: Users) {
        userCompletionHandler(user)
        attachmentsModal.dismiss(animated: true)
    }
}
// MARK: - Saved Workout Selection
extension CommentSectionCoordinator: SavedWorkoutsFlow {
    func showSavedWorkoutPicker(completion: @escaping (SavedWorkoutModel) -> Void) {
        self.savedCompletionHandle = completion
        let vc = SavedWorkoutsViewController()
        let navController = UINavigationController(rootViewController: vc)
        vc.coordinator = self
        attachmentsModal.present(navController, animated: true, completion: nil)
    }
    
    func savedWorkoutSelected(_ selectedWorkout: SavedWorkoutModel, listener: SavedWorkoutRemoveListener?) {
        savedCompletionHandle(selectedWorkout)
        attachmentsModal.dismiss(animated: true)
    }
}
