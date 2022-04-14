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
    var exercise: ExerciseModel
    
    init(navigationController: UINavigationController, exercise: ExerciseModel) {
        self.navigationController = navigationController
        self.exercise = exercise
    }
    
    func start() {
        let vc = ExerciseDescriptionViewController()
        vc.clipsVC.coordinator = self
        vc.viewModel.exercise = DiscoverExerciseModel(exerciseName: exercise.exercise)
        navigationController.pushViewController(vc, animated: true)
    }
}
extension ExerciseDiscoveryCoordinator: ClipSelectorFlow {
    
    // MARK: - Show Clip
    func clipSelected(_  model: ClipModel) {
        let keyModel = KeyClipModel(clipKey: model.id, storageURL: model.storageURL)
        let vc = ViewClipViewController()
        vc.viewModel.keyClipModel = keyModel
        vc.modalPresentationStyle = .custom
        vc.transitioningDelegate = self
        navigationController.present(vc, animated: true)
//        navigationController.present(vc, animated: true, completion: nil)
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
    func clipSelected(_ model: ClipModel)
}
