//
//  ExerciseDiscoveryCoordinator.swift
//  InTheGym
//
//  Created by Findlay Wood on 08/04/2022.
//  Copyright © 2022 FindlayWood. All rights reserved.
//

import Foundation
import UIKit

class ExerciseDiscoveryCoordinator: NSObject, Coordinator {
    // MARK: - Properties
    var childCoordinators = [Coordinator]()
    var navigationController: UINavigationController
    var exercise: DiscoverExerciseModel
    // MARK: - Initializer
    init(navigationController: UINavigationController, exercise: DiscoverExerciseModel) {
        self.navigationController = navigationController
        self.exercise = exercise
    }
    // MARK: - Starts
    func start() {
        let vc = ExerciseDescriptionViewController()
        vc.clipsVC.coordinator = self
        vc.descriptionsVC.coordinator = self
        vc.viewModel.exercise = exercise
        vc.clipsVC.viewModel.exerciseModel = exercise
        vc.descriptionsVC.viewModel.exerciseModel = exercise
        vc.hidesBottomBarWhenPushed = true
        navigationController.pushViewController(vc, animated: true)
    }
}
// MARK: - Description Flow
extension ExerciseDiscoveryCoordinator: DescriptionFlow {
    func addNewDescription(publisher: NewCommentListener) {
        let vc = DescriptionUploadViewController()
        vc.coordinator = self
        vc.viewModel.listener = publisher
        navigationController.present(vc, animated: true)
    }
    func uploadedNewDescription() {
        navigationController.dismiss(animated: true)
    }
    func dismiss() {
        navigationController.dismiss(animated: true)
    }
}
// MARK: - Clip Flow
extension ExerciseDiscoveryCoordinator: ClipSelectorFlow {
    // MARK: - Show Clip
    func clipSelected(_  model: ClipModel, fromViewControllerDelegate: CustomAnimatingClipFromVC) {
        let keyClipModel = KeyClipModel(clipKey: model.id, storageURL: model.storageURL)
        let child = ClipProfileCustomCoordinator(navigationController: navigationController, clipModel: keyClipModel, fromViewControllerDelegate: fromViewControllerDelegate)
        childCoordinators.append(child)
        child.start()
    }
}
// MARK: - Custom Clip Picker
extension ExerciseDiscoveryCoordinator: UIViewControllerTransitioningDelegate {
    func presentationController(forPresented presented: UIViewController, presenting: UIViewController?, source: UIViewController) -> UIPresentationController? {
        let controller = BottomViewPresentationController(presentedViewController: presented, presenting: presenting)
        controller.viewHeightPrecentage = 1
        return controller
    }
}
// MARK: - Clip Selector Flow
protocol ClipSelectorFlow: AnyObject {
    func clipSelected(_ model: ClipModel, fromViewControllerDelegate: CustomAnimatingClipFromVC)
}
// MARK: - Descriptions Flow
protocol DescriptionFlow: AnyObject {
    func addNewDescription(publisher: NewCommentListener)
    func uploadedNewDescription()
    func dismiss()
}
