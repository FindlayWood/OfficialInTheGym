//
//  EditProfileCoordinator.swift
//  InTheGym
//
//  Created by Findlay Wood on 13/05/2022.
//  Copyright © 2022 FindlayWood. All rights reserved.
//

import UIKit

class EditProfileCoordinator: Coordinator {
    var childCoordinators = [Coordinator]()
    var navigationController: UINavigationController
    var modalNavigationController: UINavigationController?
    var imagePickerCompletionHandler: ((UIImage) -> Void)?
    
    init(navigationController: UINavigationController) {
        self.navigationController = navigationController
    }
    
    func start() {
        modalNavigationController = UINavigationController()
        let vc = EditProfileViewController()
        vc.coordinator = self
        modalNavigationController?.setViewControllers([vc], animated: true)
        if let modalNavigationController = modalNavigationController {
            modalNavigationController.modalPresentationStyle = .fullScreen
            navigationController.present(modalNavigationController, animated: true)
        }
    }
}
extension EditProfileCoordinator {
    func showImagePicker(completion: @escaping (UIImage) -> Void) {
        self.imagePickerCompletionHandler = completion
        guard let modalNavigationController = modalNavigationController else {return}
        let child = ImagePickerCoordinator(navigationController: modalNavigationController)
        childCoordinators.append(child)
        child.parentCoordinator = self
        child.start()
    }
    func dismiss() {
        navigationController.dismiss(animated: true)
    }
}

// MARK: Image Picking Flow
extension EditProfileCoordinator: ImagePickerFlow {
    func didFinishPickingImage(coordinator: Coordinator, _ image: UIImage) {
        imagePickerCompletionHandler?(image)
        childDidFinish(coordinator)
    }
}
