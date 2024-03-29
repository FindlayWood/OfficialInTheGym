//
//  CircuitCoordinator.swift
//  InTheGym
//
//  Created by Findlay Wood on 14/05/2021.
//  Copyright © 2021 FindlayWood. All rights reserved.
//

import Foundation
import UIKit

class CircuitCoordinator: Coordinator {
    var childCoordinators = [Coordinator]()
    var navigationController: UINavigationController
    weak var parentDelegate: CircuitParentDelegate?
    
    init(navigationController: UINavigationController, parentDelegte: CircuitParentDelegate) {
        self.navigationController = navigationController
        self.parentDelegate = parentDelegte
    }
    
    func start() {
        let vc = CreateCircuitViewController()
//        vc.coordinator = self
        navigationController.pushViewController(vc, animated: true)
    }
}
// MARK: - Parent Creation Flow
extension CircuitCoordinator {
    func completedCircuit(circuitModel: circuit) {
        parentDelegate?.finishedCreatingCircuit(circuitModel: circuitModel)
    }
}

// MARK: - Creation Flow
extension CircuitCoordinator: CreationFlow {
    func addExercise(_ circuit: exercise) {
        let vc = ExerciseSelectionViewController()
        navigationController.pushViewController(vc, animated: true)
    }
    func otherSelected(_ exercise: exercise) {
        let vc = OtherExerciseViewController()
        navigationController.present(vc, animated: true, completion: nil)
    }
    
    func exerciseSelected(_ exercise: exercise) {
        let vc = SetSelectionViewController()
        navigationController.pushViewController(vc, animated: true)
    }
    
    func repsSelected(_ exercise: exercise) {
        let vc = WeightSelectionViewController()
        navigationController.pushViewController(vc, animated: true)
    }
    func weightSelected(_ exercise: exercise) {
//        CreateCircuitViewController.circuitExercises.append(exercise)
        let viewControllers: [UIViewController] = navigationController.viewControllers as [UIViewController]
        for controller in viewControllers {
            if controller.isKind(of: CreateCircuitViewController.self) {
                navigationController.popToViewController(controller, animated: true)
                break
            }
        }
    }
    func completeExercise() {
        // not implemented
    }
}

extension CircuitCoordinator: RegularAndCircuitFlow {
    func setsSelected(_ exercise: exercise) {
        let vc = RepSelectionViewController()
//        vc.coordinator = self
//        vc.newExercise = exercise
        navigationController.pushViewController(vc, animated: true)
    }
}
