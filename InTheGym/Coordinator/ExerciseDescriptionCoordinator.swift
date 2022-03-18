//
//  ExerciseDescriptionCoordinator.swift
//  InTheGym
//
//  Created by Findlay Wood on 18/03/2022.
//  Copyright © 2022 FindlayWood. All rights reserved.
//

import Foundation
import UIKit

class ExerciseDescriptionCoordinator: NSObject, Coordinator {
    var childCoordinators = [Coordinator]()
    var navigationController: UINavigationController
    var exerciseModel: DiscoverExerciseModel
    
    init(navigationController: UINavigationController, exercise: DiscoverExerciseModel) {
        self.navigationController = navigationController
        self.exerciseModel = exercise
    }
    
    func start() {
        let vc = ExerciseDescriptionViewController()
        vc.viewModel.exercise = exerciseModel
        vc.coordinator = self
        vc.hidesBottomBarWhenPushed = true
        navigationController.pushViewController(vc, animated: true)
    }
}

extension ExerciseDescriptionCoordinator {
    
    func addDescription(_ model: DescriptionModel, listener: NewDescriptionListener) {
        let vc = DescriptionUploadViewController()
        vc.viewModel.descriptionModel = model
        vc.viewModel.listener = listener
        vc.modalPresentationStyle = .fullScreen
        navigationController.present(vc, animated: true)
    }
    func posted() {
        navigationController.dismiss(animated: true)
    }
}
