//
//  PracticeTrackerCoordinator.swift
//  InTheGym
//
//  Created by Findlay-Personal on 03/11/2022.
//  Copyright © 2022 FindlayWood. All rights reserved.
//

import UIKit

/// responsible for the navigation flow for CMJ jumps
/// home page -> recording jumo -> jump replay -> results
class PracticeTrackerCoordinator: NSObject, Coordinator {
    // MARK: - Properties
    var childCoordinators: [Coordinator] = [Coordinator]()
    var navigationController: UINavigationController
    
    
    // MARK: - Initializer
    init(navigationController: UINavigationController) {
        self.navigationController = navigationController
    }
    
    // MARK: - Start
    func start() {
        let vc = PracticeTrackerHomeViewController()
        vc.coordinator = self
        navigationController.pushViewController(vc, animated: true)
    }
}
// MARK: - Methods
extension PracticeTrackerCoordinator {
    func showDetail(_ model: PracticeTrackerModel) {
        let vc = PracticeTrackerDetailViewController()
        vc.practiceTrackerModel = model
        navigationController.pushViewController(vc, animated: true)
    }
}
