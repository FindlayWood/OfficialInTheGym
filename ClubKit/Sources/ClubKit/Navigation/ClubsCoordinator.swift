//
//  File.swift
//  
//
//  Created by Findlay-Personal on 10/05/2023.
//

import UIKit

class ClubsCoordinator: ClubsFlow {
    
    var navigationController: UINavigationController
    var viewControllerFactoy: ViewControllerFactory
    
    init(navigationController: UINavigationController, viewControllerFactory: ViewControllerFactory) {
        self.navigationController = navigationController
        self.viewControllerFactoy = viewControllerFactory
    }
    
    func start() {
        let vc = viewControllerFactoy.makeClubsViewController()
        navigationController.pushViewController(vc, animated: false)
    }
    func goToClub() {

    }
}

protocol ClubsFlow: Coordinator {
    func goToClub()
}
