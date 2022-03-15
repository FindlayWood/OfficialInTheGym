//
//  ClipCoordinator.swift
//  InTheGym
//
//  Created by Findlay Wood on 09/02/2022.
//  Copyright © 2022 FindlayWood. All rights reserved.
//

import Foundation
import UIKit

class ClipCoordinator: NSObject, Coordinator {
    var childCoordinators = [Coordinator]()
    var navigationController: UINavigationController
    var modalNavigationController: UINavigationController?
    var workout: WorkoutModel
    var exercise: DiscoverExerciseModel
    var addingDelegate: ClipAdding
    
    init(navigationController: UINavigationController, workout: WorkoutModel, exercise: DiscoverExerciseModel, addingDelegate: ClipAdding) {
        self.navigationController = navigationController
        self.workout = workout
        self.exercise = exercise
        self.addingDelegate = addingDelegate
    }
    
    func start() {
        
        let vc = RecordClipViewController()
//        self.modalNavigationController = UINavigationController(rootViewController: vc)
        vc.coordinator = self
        vc.viewModel.workoutModel = workout
        vc.viewModel.exerciseModel = exercise
        vc.viewModel.addingDelegate = addingDelegate
        vc.modalPresentationStyle = .fullScreen
        vc.modalTransitionStyle = .coverVertical
        navigationController.present(vc, animated: true)
//        if let modalNavigationController = modalNavigationController {
//            modalNavigationController.modalPresentationStyle = .fullScreen
//            navigationController.setNavigationBarHidden(true, animated: false)
//            navigationController.present(modalNavigationController, animated: true, completion: nil)
//        }

    }
}

extension ClipCoordinator {
    func finishedRecording(_ clipStorageModel: ClipStorageModel) {
//        guard let modalNavigationController = modalNavigationController else {return}
        let vc = RecordedClipPlayerViewController()
        vc.viewModel.exerciseModel = exercise
        vc.viewModel.workoutModel = workout
        vc.viewModel.clipStorageModel = clipStorageModel
        vc.viewModel.addDelegate = addingDelegate
//        vc.modalPresentationStyle = .fullScreen
//        vc.navigationController?.setNavigationBarHidden(true, animated: false)
        navigationController.pushViewController(vc, animated: false)
    }
}
