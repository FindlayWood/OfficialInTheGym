//
//  SingleSetCoordinator.swift
//  InTheGym
//
//  Created by Findlay Wood on 11/05/2022.
//  Copyright © 2022 FindlayWood. All rights reserved.
//
import UIKit

class SingleSetCoordinator: NSObject, Coordinator {
    var childCoordinators = [Coordinator]()
    var navigationController: UINavigationController
    var fromViewControllerDelegate: AnimatingSingleSet
    var setModel: ExerciseSet
    
    init(navigationController: UINavigationController, fromViewControllerDelegate: AnimatingSingleSet, setModel: ExerciseSet) {
        self.navigationController = navigationController
        self.fromViewControllerDelegate = fromViewControllerDelegate
        self.setModel = setModel
    }
    
    func start() {
        let vc = DisplaySingleSetViewController()
        vc.coordinator = self
        vc.viewModel.setModel = setModel
        vc.modalPresentationStyle = .custom
        vc.hidesBottomBarWhenPushed = true
        vc.transitioningDelegate = self
        navigationController.present(vc, animated: true)
    }
    
    func dismissVC() {
        navigationController.dismiss(animated: true)
    }
}

extension SingleSetCoordinator: UIViewControllerTransitioningDelegate {
    func animationController(forPresented presented: UIViewController, presenting: UIViewController, source: UIViewController) -> UIViewControllerAnimatedTransitioning? {
        guard
            let secondViewController = presented as? DisplaySingleSetViewController,
            let selectedCellImageViewSnapshot = fromViewControllerDelegate.selectedSetCellImageViewSnapshot
            else { return nil }

        return ShowSingleSetCustomTransition(animationType: .present, firstViewController: fromViewControllerDelegate, secondViewController: secondViewController, selectedCellImageViewSnapshot: selectedCellImageViewSnapshot)
       
    }

    func animationController(forDismissed dismissed: UIViewController) -> UIViewControllerAnimatedTransitioning? {
        guard let secondViewController = dismissed as? DisplaySingleSetViewController,
              let selectedCellImageViewSnapshot = fromViewControllerDelegate.selectedSetCellImageViewSnapshot
            else { return nil }
        
        return ShowSingleSetCustomTransition(animationType: .dismiss, firstViewController: fromViewControllerDelegate, secondViewController: secondViewController, selectedCellImageViewSnapshot: selectedCellImageViewSnapshot)
    }

}
