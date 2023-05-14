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
    var coordinatorFactory: CoordinatorFactory
    
    init(navigationController: UINavigationController, viewControllerFactory: ViewControllerFactory, coordinatorFactory: CoordinatorFactory) {
        self.navigationController = navigationController
        self.viewControllerFactoy = viewControllerFactory
        self.coordinatorFactory = coordinatorFactory
    }
    
    func start() {
        let vc = viewControllerFactoy.makeClubsViewController(flow: self)
        navigationController.pushViewController(vc, animated: false)
    }
    func goToClub(_ model: RemoteClubModel) {
        let child = coordinatorFactory.makeClubHomeCoordinator(with: model)
        child.start()
    }
}

protocol ClubsFlow: Coordinator {
    func goToClub(_ model: RemoteClubModel)
}
