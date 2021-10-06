//
//  AttachingClipCoordinator.swift
//  InTheGym
//
//  Created by Findlay Wood on 31/08/2021.
//  Copyright © 2021 FindlayWood. All rights reserved.
//

import UIKit

class AttachingClipCoordinator: NSObject, Coordinator {
    var childCoordinators = [Coordinator]()
    var navigationController: UINavigationController
    
    init(navigationController: UINavigationController) {
        self.navigationController = navigationController
    }
    func start() {
        let vc = AttachingClipViewController()
        vc.coordinator = self
        vc.modalPresentationStyle = .custom
        vc.transitioningDelegate = self
        navigationController.present(vc, animated: true, completion: nil)
    }
}

// MARK: - Custom Clip Picker
extension AttachingClipCoordinator: UIViewControllerTransitioningDelegate {
    
    func presentationController(forPresented presented: UIViewController, presenting: UIViewController?, source: UIViewController) -> UIPresentationController? {
        return BottomViewPresentationController(presentedViewController: presented, presenting: presenting)
    }
}
