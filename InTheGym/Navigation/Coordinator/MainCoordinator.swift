//
//  MainCoordinator.swift
//  InTheGym
//
//  Created by Findlay Wood on 04/05/2021.
//  Copyright © 2021 FindlayWood. All rights reserved.
//

import Foundation
import UIKit

class MainCoordinator: Coordinator {
    
    var childCoordinators = [Coordinator]()
    var navigationController: UINavigationController
    
    init(navigationController: UINavigationController){
        self.navigationController = navigationController
        self.navigationController.navigationBar.setBackgroundImage(UIImage(), for: .default)
        self.navigationController.navigationBar.shadowImage = UIImage()
        self.navigationController.navigationBar.tintColor = .white
    }
    
    func start() {
        let vc = LaunchPageViewController()
        navigationController.pushViewController(vc, animated: false)
    }
    
    func coordinateToTabBar() {
        let tabBar = TabBarCoordinator(navigationController: navigationController)
        coordinate(to: tabBar)
    }
}
