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
    private var completion: (UIImage) -> Void = { _ in }
    private var savedCompletionHandle: (SavedWorkoutModel) -> Void = { _ in }
    var postable: Postable
    var listener: NewPostListener?
    var workout: WorkoutModel?
    
    init(navigationController: UINavigationController, postable: Postable, listener: NewPostListener?, workout: WorkoutModel? = nil) {
        self.navigationController = navigationController
        self.postable = postable
        self.listener = listener
        self.workout = workout
    }
    
    func start() {
        self.modalNavigationController = UINavigationController()
        let vc = CreateNewPostViewController()
        modalNavigationController?.setViewControllers([vc], animated: false)
        vc.coordinator = self
        vc.viewModel.postable = postable
        vc.viewModel.listener = listener
        vc.viewModel.attachedWorkout = workout
        if let modalNavigationController = modalNavigationController {
            modalNavigationController.modalPresentationStyle = .fullScreen
            navigationController.present(modalNavigationController, animated: true, completion: nil)
        }
    }
}

// MARK: Flow Methods
extension CreateNewPostCoordinator {
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
    func posted() {
        navigationController.dismiss(animated: true)
    }
}

extension CreateNewPostCoordinator: SavedWorkoutsFlow {
    func showSavedWorkoutPicker(completion: @escaping (SavedWorkoutModel) -> Void) {
        self.savedCompletionHandle = completion
        guard let modalNavigationController = modalNavigationController else {return}
        let vc = SavedWorkoutsViewController()
        vc.coordinator = self
        modalNavigationController.present(vc, animated: true, completion: nil)
    }
    
    func savedWorkoutSelected(_ selectedWorkout: SavedWorkoutModel, listener: SavedWorkoutRemoveListener?) {
        savedCompletionHandle(selectedWorkout)
        guard let modalNavigationController = modalNavigationController else {return}
        modalNavigationController.dismiss(animated: true)
    }
}

// MARK: Image Picking Flow
extension CreateNewPostCoordinator: ImagePickerFlow {
    func didFinishPickingImage(coordinator: Coordinator, _ image: UIImage) {
        completion(image)
        childDidFinish(coordinator)
    }
}


