//
//  ImagePickerCoordinator.swift
//  InTheGym
//
//  Created by Findlay Wood on 30/08/2021.
//  Copyright © 2021 FindlayWood. All rights reserved.
//

import UIKit

protocol ImagePickerFlow: AnyObject {
    func didFinishPickingImage(coordinator: Coordinator, _ image: UIImage)
}

class ImagePickerCoordinator: NSObject, Coordinator {
    var childCoordinators = [Coordinator]()
    var navigationController: UINavigationController
    weak var parentCoordinator: ImagePickerFlow?
    
    init(navigationController: UINavigationController) {
        self.navigationController = navigationController
    }
    
    func start() {
        let imagePicker = UIImagePickerController()
        imagePicker.delegate = self
        navigationController.present(imagePicker, animated: true, completion: nil)
    }
}

extension ImagePickerCoordinator: UIImagePickerControllerDelegate, UINavigationControllerDelegate {
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey : Any]) {
        if let image = info[.originalImage] as? UIImage {
            parentCoordinator?.didFinishPickingImage(coordinator: self, image)
        }
    }
}
