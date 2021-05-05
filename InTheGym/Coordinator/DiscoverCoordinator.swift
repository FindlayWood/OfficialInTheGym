//
//  DiscoverCoordinator.swift
//  InTheGym
//
//  Created by Findlay Wood on 05/05/2021.
//  Copyright © 2021 FindlayWood. All rights reserved.
//

import Foundation
import UIKit

protocol DiscoverFlow {
    func workoutSelected()
}

class DiscoverCoordinator: Coordinator, DiscoverFlow {

    var childCoordinators = [Coordinator]()
    var navigationController: UINavigationController
    
    init(navigationController: UINavigationController){
        self.navigationController = navigationController
        self.navigationController.navigationBar.setBackgroundImage(UIImage(), for: .default)
        self.navigationController.navigationBar.shadowImage = UIImage()
        self.navigationController.navigationBar.tintColor = .white
    }
    
    func start() {
        let vc = DiscoverPageViewController.instantiate()
        vc.coordinator = self
        navigationController.pushViewController(vc, animated: true)
    }
    
    func workoutSelected() {
        print("show workout...")
    }
    
}
