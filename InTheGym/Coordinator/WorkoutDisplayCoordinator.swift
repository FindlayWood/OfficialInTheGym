//
//  WorkoutDisplayCoordinator.swift
//  InTheGym
//
//  Created by Findlay Wood on 21/01/2022.
//  Copyright © 2022 FindlayWood. All rights reserved.
//

import Foundation
import UIKit

class WorkoutDisplayCoordinator: NSObject, Coordinator {
    var childCoordinators = [Coordinator]()
    var navigationController: UINavigationController
    var workout: WorkoutModel
    
    init(navigationController: UINavigationController, workout: WorkoutModel) {
        self.navigationController = navigationController
        self.workout = workout
    }
    
    func start() {
        let vc = WorkoutDisplayViewController()
        vc.viewModel.workout = workout
        vc.coordinator = self
        vc.hidesBottomBarWhenPushed = true
        navigationController.pushViewController(vc, animated: true)
    }
}
// MARK: - Methods
extension WorkoutDisplayCoordinator {
    func complete(_ workout: WorkoutModel) {
        
    }
    func showEMOM(_ emom: EMOMModel) {
        let vc = DisplayEMOMViewController()
        vc.viewModel.emomModel = emom
        navigationController.pushViewController(vc, animated: true)
    }
    func showCircuit(_ circuit: CircuitModel) {
        
    }
    func showAMRAP(_ amrap: AMRAPModel) {
        
    }
}
