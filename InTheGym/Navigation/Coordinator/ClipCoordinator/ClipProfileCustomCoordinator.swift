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
    var subscriptionManager: PurchaseManager
    
    init(navigationController: UINavigationController, clipModel: KeyClipModel, fromViewControllerDelegate: CustomAnimatingClipFromVC, subscriptionManager: PurchaseManager) {
        self.navigationController = navigationController
        self.clipModel = clipModel
        self.fromViewControllerDelegate = fromViewControllerDelegate
        self.subscriptionManager = subscriptionManager
    }
    
    func start() {
        if subscriptionManager.hasUnlockedPro {
            let vc = ViewClipViewController()
            vc.newCoordinator = self
            vc.viewModel.keyClipModel = clipModel
            vc.modalPresentationStyle = .custom
            vc.hidesBottomBarWhenPushed = true
            vc.transitioningDelegate = self
            navigationController.present(vc, animated: true)
        } else {
            let vc = PremiumAccountViewController()
            vc.modalPresentationStyle = .fullScreen
            vc.viewModel = AccountCreatedViewModel(purchaseManager: subscriptionManager)
            navigationController.present(vc, animated: true)
        }
    }
    
    func dismissVC() {
        navigationController.dismiss(animated: true)
    }
}

extension ClipProfileCustomCoordinator: UIViewControllerTransitioningDelegate {
    func animationController(forPresented presented: UIViewController, presenting: UIViewController, source: UIViewController) -> UIViewControllerAnimatedTransitioning? {
        guard
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
