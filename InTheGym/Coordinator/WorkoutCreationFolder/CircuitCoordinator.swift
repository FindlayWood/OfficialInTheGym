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
    
    init(navigationController: UINavigationController) {
        self.navigationController = navigationController
    }
    
    func start() {
        let vc = CreateCircuitViewController.instantiate()
        vc.coordinator = self
        navigationController.pushViewController(vc, animated: true)
    }
}

extension CircuitCoordinator: CircuitFlow {
    func addExercise() {
        let vc = BodyTypeViewController.instantiate()
        vc.coordinator = self
        navigationController.pushViewController(vc, animated: true)
    }
    
    func setsSelected() {
        
    }
    
    func bodyTypeSelected(_ type: bodyType) {
        print(type)
    }
    
    func exerciseSelected() {
        
    }
    
    func repsSelected() {
        
    }
    
    
}
