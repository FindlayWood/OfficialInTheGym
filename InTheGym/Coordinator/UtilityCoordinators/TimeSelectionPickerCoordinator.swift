//
//  TimeSelectionPickerCoordinator.swift
//  InTheGym
//
//  Created by Findlay Wood on 21/09/2021.
//  Copyright © 2021 FindlayWood. All rights reserved.
//

import UIKit

class TimeSelectionPickerCoordinator: NSObject, Coordinator {
    var childCoordinators = [Coordinator]()
    var navigationController: UINavigationController
    var parent: TimeSelectionParentDelegate
    var currentTime: Int
    //var controller: BottomViewPresentationController?
    
    init(navigationController: UINavigationController, parent: TimeSelectionParentDelegate, currentTime: Int) {
        self.navigationController = navigationController
        self.parent = parent
        self.currentTime = currentTime
    }
    
    func start() {
        let vc = TimeSelectionViewController()
        vc.coordinator = self
        vc.parentDelegate = parent
        vc.currentSelectedTime = currentTime
        vc.modalPresentationStyle = .custom
        vc.transitioningDelegate = self
        navigationController.present(vc, animated: true, completion: nil)
    }
}

//extension TimeSelectionPickerCoordinator {
//    func dismissPicker() {
//        controller?.dismissalTransitionWillBegin()
//        //navigationController.dismiss(animated: true, completion: nil)
//    }
//}

// MARK: - Custom Clip Picker
extension TimeSelectionPickerCoordinator: UIViewControllerTransitioningDelegate {
    
    func presentationController(forPresented presented: UIViewController, presenting: UIViewController?, source: UIViewController) -> UIPresentationController? {
        let controller = BottomViewPresentationController(presentedViewController: presented, presenting: presenting)
        controller.viewHeightPrecentage = 0.5
        return controller
    }
}
