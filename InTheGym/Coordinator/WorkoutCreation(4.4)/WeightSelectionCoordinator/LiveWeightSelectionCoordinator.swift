//
//  LiveWeightSelectionCoordinator.swift
//  InTheGym
//
//  Created by Findlay Wood on 06/01/2022.
//  Copyright © 2022 FindlayWood. All rights reserved.
//

import Foundation
import UIKit

class LiveWeightSelectionCoordinator: NSObject, Coordinator {
    var childCoordinators = [Coordinator]()
    var navigationController: UINavigationController
    
    init(navigationController: UINavigationController) {
        self.navigationController = navigationController
    }
    
    func start() {
        let vc = ExerciseSelectionViewController()
        navigationController.pushViewController(vc, animated: true)
    }
}

// MARK: - Weight Selection Flow
extension LiveWeightSelectionCoordinator: WeightSelectionFlow {
    func next() {
        
    }
}
