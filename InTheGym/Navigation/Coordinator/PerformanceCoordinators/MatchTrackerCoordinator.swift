//
//  MatchTrackerCoordinator.swift
//  InTheGym
//
//  Created by Findlay Wood on 19/10/2022.
//  Copyright © 2022 FindlayWood. All rights reserved.
//

import UIKit

/// responsible for the navigation flow for CMJ jumps
/// home page -> recording jumo -> jump replay -> results
class MatchTrackerCoordinator: NSObject, Coordinator {
    // MARK: - Properties
    var childCoordinators: [Coordinator] = [Coordinator]()
    var navigationController: UINavigationController
    
    
    // MARK: - Initializer
    init(navigationController: UINavigationController) {
        self.navigationController = navigationController
    }
    
    // MARK: - Start
    func start() {
        let vc = MatchTrackerViewController()
        vc.coordinator = self
        navigationController.pushViewController(vc, animated: true)
    }
}
// MARK: - Methods
extension MatchTrackerCoordinator {
    func showDetail(_ model: MatchTrackerModel) {
        // TODO: Show Detail
    }
}
