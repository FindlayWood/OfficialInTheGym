//
//  CreateNewPostCoordinator.swift
//  InTheGym
//
//  Created by Findlay Wood on 30/08/2021.
//  Copyright © 2021 FindlayWood. All rights reserved.
//

import UIKit

class CreateNewPostCoordinator: NSObject, Coordinator {
    var childCoordinators = [Coordinator]()
    var navigationController: UINavigationController
    var modalNavigationController: UINavigationController?
    var attachmentsModal: UINavigationController!
    private var completion: (UIImage) -> Void = { _ in }
    private var savedCompletionHandle: (SavedWorkoutModel) -> Void = { _ in }
    private var userCompletionHandler: (Users) -> Void = { _ in }
    var postable: Postable
    var workout: WorkoutModel?
    
    init(navigationController: UINavigationController, postable: Postable, workout: WorkoutModel? = nil) {
        self.navigationController = navigationController
        self.postable = postable
        self.workout = workout
    }
    
    func start() {
        self.modalNavigationController = UINavigationController()
        let vc = CreateNewPostViewController()
        modalNavigationController?.setViewControllers([vc], animated: false)
        vc.coordinator = self
        vc.viewModel.postable = postable
        vc.viewModel.attachedWorkout = workout
        if let modalNavigationController = modalNavigationController {
            modalNavigationController.modalPresentationStyle = .fullScreen
            navigationController.present(modalNavigationController, animated: true, completion: nil)
        }
    }
}

// MARK: Flow Methods
extension CreateNewPostCoordinator {
    func showAttachments(_ viewModel: NewPostViewModel) {
        guard let modalNavigationController else {return}
        let vc = AttachmentsViewController()
        attachmentsModal = UINavigationController(rootViewController: vc)
        vc.viewModel = viewModel
        vc.coordinator = self
        modalNavigationController.present(attachmentsModal, animated: true, completion: nil)
    }
    func showPrivacy(_ viewModel: NewPostViewModel) {
        guard let modalNavigationController else {return}
        let vc = PrivacySettingsViewController()
        vc.viewModel = viewModel
        modalNavigationController.present(vc, animated: true)
    }
    
    func showImagePicker(completion: @escaping (UIImage) -> Void) {
        self.completion = completion
        guard let modalNavigationController = modalNavigationController else {return}
        let child = ImagePickerCoordinator(navigationController: modalNavigationController)
        childCoordinators.append(child)
        child.parentCoordinator = self
        child.start()
    }
    
    func showClipPicker() {
        guard let modalNavigationController = modalNavigationController else {return}
        let child = AttachingClipCoordinator(navigationController: modalNavigationController)
        childCoordinators.append(child)
        child.start()
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
    func posted() {
        navigationController.dismiss(animated: true)
    }
}

extension CreateNewPostCoordinator: SavedWorkoutsFlow {
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

// MARK: Image Picking Flow
extension CreateNewPostCoordinator: ImagePickerFlow {
    func didFinishPickingImage(coordinator: Coordinator, _ image: UIImage) {
        completion(image)
        childDidFinish(coordinator)
    }
}
// MARK: - User Selection
extension CreateNewPostCoordinator: UserSearchFlow {
    func userSelected(_ user: Users) {
        userCompletionHandler(user)
        attachmentsModal.dismiss(animated: true)
    }
}

