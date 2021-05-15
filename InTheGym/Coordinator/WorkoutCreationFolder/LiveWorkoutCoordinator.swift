//
//  LiveWorkoutCoordinator.swift
//  InTheGym
//
//  Created by Findlay Wood on 14/05/2021.
//  Copyright © 2021 FindlayWood. All rights reserved.
//

import Foundation
import UIKit

class LiveWorkoutCoordinator: Coordinator {
    var childCoordinators = [Coordinator]()
    var navigationController: UINavigationController
    
    init(navigationController: UINavigationController) {
        self.navigationController = navigationController
    }
    
    func start() {
        
    }
}

extension LiveWorkoutCoordinator: LiveWorkoutFlow {
    func addExercise() {
        
    }
    
    func weightSelected() {
        
    }
    
    func bodyTypeSelected(_ type: bodyType) {
        
    }
    
    func exerciseSelected() {
        
    }
    
    func repsSelected() {
        
    }
    
    
}
