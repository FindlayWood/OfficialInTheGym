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
    var childCoordinators = [Coordinator]()
    var navigationController: UINavigationController
    var exercise: DiscoverExerciseModel
    
    init(navigationController: UINavigationController, exercise: DiscoverExerciseModel) {
        self.navigationController = navigationController
        self.exercise = exercise
    }
    
    func start() {
        let vc = ExerciseDescriptionViewController()
        vc.clipsVC.coordinator = self
        vc.viewModel.exercise = exercise
        vc.clipsVC.viewModel.exerciseModel = exercise
        vc.descriptionsVC.viewModel.exerciseModel = exercise
        vc.hidesBottomBarWhenPushed = true
        navigationController.pushViewController(vc, animated: true)
    }
}
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
