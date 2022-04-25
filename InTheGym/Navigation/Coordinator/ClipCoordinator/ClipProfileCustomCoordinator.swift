//
//  ClipProfileCustomCoordinator.swift
//  InTheGym
//
//  Created by Findlay Wood on 16/04/2022.
//  Copyright © 2022 FindlayWood. All rights reserved.
//

import Foundation
import UIKit

class ClipProfileCustomCoordinator: NSObject, Coordinator {
    var childCoordinators = [Coordinator]()
    var navigationController: UINavigationController
    var clipModel: KeyClipModel
    var fromViewControllerDelegate: CustomAnimatingClipFromVC
    
    init(navigationController: UINavigationController, clipModel: KeyClipModel, fromViewControllerDelegate: CustomAnimatingClipFromVC) {
        self.navigationController = navigationController
        self.clipModel = clipModel
        self.fromViewControllerDelegate = fromViewControllerDelegate
    }
    
    func start() {
//        let keyModel = KeyClipModel(clipKey: clipModel.id, storageURL: clipModel.storageURL)
        let vc = ViewClipViewController()
        vc.newCoordinator = self
        vc.viewModel.keyClipModel = clipModel
        vc.modalPresentationStyle = .custom
        vc.hidesBottomBarWhenPushed = true
        vc.transitioningDelegate = self
        navigationController.present(vc, animated: true)
    }
    
    func dismissVC() {
        navigationController.dismiss(animated: true)
    }
}

extension ClipProfileCustomCoordinator: UIViewControllerTransitioningDelegate {
    func animationController(forPresented presented: UIViewController, presenting: UIViewController, source: UIViewController) -> UIViewControllerAnimatedTransitioning? {
        guard
//            let firstViewController = presenting as? CustomAnimatingClipFromVC,
            let secondViewController = presented as? ViewClipViewController,
            let selectedCellImageViewSnapshot = fromViewControllerDelegate.selectedCellImageViewSnapshot
            else { return nil }

        return ShowClipCustomTransition(animationType: .present, firstViewController: fromViewControllerDelegate, secondViewController: secondViewController, selectedCellImageViewSnapshot: selectedCellImageViewSnapshot)
       
    }

    func animationController(forDismissed dismissed: UIViewController) -> UIViewControllerAnimatedTransitioning? {
        guard let secondViewController = dismissed as? ViewClipViewController,
              let selectedCellImageViewSnapshot = fromViewControllerDelegate.selectedCellImageViewSnapshot
            else { return nil }
        
        return ShowClipCustomTransition(animationType: .dismiss, firstViewController: fromViewControllerDelegate, secondViewController: secondViewController, selectedCellImageViewSnapshot: selectedCellImageViewSnapshot)
    }

}
