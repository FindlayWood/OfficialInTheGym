//
//  SingleSetCoordinator.swift
//  InTheGym
//
//  Created by Findlay Wood on 11/05/2022.
//  Copyright © 2022 FindlayWood. All rights reserved.
//
import UIKit
import Combine

class SingleSetCoordinator: NSObject, Coordinator {
    // MARK: - Properties
    var childCoordinators = [Coordinator]()
    var navigationController: UINavigationController
    var fromViewControllerDelegate: AnimatingSingleSet
    var setModel: ExerciseSet
    var editButtonAction: PassthroughSubject<ExerciseSet,Never>?
    var isEditable: Bool?
    // MARK: - Initializer
    init(navigationController: UINavigationController, fromViewControllerDelegate: AnimatingSingleSet, setModel: ExerciseSet, editAction: PassthroughSubject<ExerciseSet,Never>? = nil, isEditable: Bool? = false) {
        self.navigationController = navigationController
        self.fromViewControllerDelegate = fromViewControllerDelegate
        self.setModel = setModel
        self.editButtonAction = editAction
        self.isEditable = isEditable
    }
    // MARK: - Start
    func start() {
        let vc = DisplaySingleSetViewController()
        vc.coordinator = self
        vc.viewModel.setModel = setModel
        vc.viewModel.editSetAction = editButtonAction
        vc.viewModel.isEditable = isEditable
        vc.modalPresentationStyle = .custom
        vc.hidesBottomBarWhenPushed = true
        vc.transitioningDelegate = self
        navigationController.present(vc, animated: true)
    }
}
// MARK: - Flow
extension SingleSetCoordinator {
    func editSet() {
        dismissVC()
    }
    func dismissVC() {
        navigationController.dismiss(animated: true)
    }
}
// MARK: - Custom Transition
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
