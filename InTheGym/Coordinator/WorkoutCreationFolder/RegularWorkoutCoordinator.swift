//
//  CreatingWorkoutCoordinator.swift
//  InTheGym
//
//  Created by Findlay Wood on 14/05/2021.
//  Copyright © 2021 FindlayWood. All rights reserved.
//

import Foundation
import UIKit

protocol CreationDelegate: AnyObject {
    func addExercise()
    func bodyTypeSelected(_ type: bodyType)
    func exerciseSelected()
    func repsSelected()
}

protocol RegularWorkoutFlow: CreationDelegate {
    func addCircuit()
    func setsSelected()
    func weightSelected()
    func noteAdded()
}

protocol LiveWorkoutFlow: CreationDelegate {
    func weightSelected()
}

protocol CircuitFlow: CreationDelegate {
    func setsSelected()
}

protocol AmrapFlow: CreationDelegate {
    
}


class RegularWorkoutCoordinator: Coordinator {
    var childCoordinators = [Coordinator]()
    var navigationController: UINavigationController
    
    init(navigationController: UINavigationController) {
        self.navigationController = navigationController
    }
    
    func start() {
        let vc = AddWorkoutHomeViewController.instantiate()
        AddWorkoutHomeViewController.groupBool = false
        vc.coordinator = self
        vc.playerBool = true
        vc.hidesBottomBarWhenPushed = true
        navigationController.pushViewController(vc, animated: true)
    }
}

extension RegularWorkoutCoordinator: RegularWorkoutFlow {
    func addCircuit() {
        let child = CircuitCoordinator(navigationController: navigationController)
        childCoordinators.append(child)
        child.start()
    }
    func addExercise() {
        let vc = BodyTypeViewController.instantiate()
        vc.coordinator = self
        navigationController.pushViewController(vc, animated: true)
    }
    
    func setsSelected() {
        let vc = NewRepsViewController()
        navigationController.pushViewController(vc, animated: true)
    }
    
    func weightSelected() {
        let vc = NoteViewController()
        navigationController.pushViewController(vc, animated: true)
    }
    
    func noteAdded() {
        navigationController.popToRootViewController(animated: true)
    }
    
    func bodyTypeSelected(_ type: bodyType) {
        print(type)
    }
    
    func exerciseSelected() {
        let vc = ExerciseSetsViewController()
        navigationController.pushViewController(vc, animated: true)
    }
    
    func repsSelected() {
        let vc = NewWeightViewController()
        navigationController.pushViewController(vc, animated: true)
    }
    
    
}

