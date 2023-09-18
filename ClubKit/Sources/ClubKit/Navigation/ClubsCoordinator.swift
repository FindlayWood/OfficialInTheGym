//
//  File.swift
//  
//
//  Created by Findlay-Personal on 10/05/2023.
//

import UIKit

class ClubsCoordinator: ClubsFlow {
    
    var navigationController: UINavigationController
    var viewControllerFactoy: BaseViewControllerFactory
    var coordinatorFactory: ClubsCoordinatorFactory
    
    init(navigationController: UINavigationController, viewControllerFactory: BaseViewControllerFactory, coordinatorFactory: ClubsCoordinatorFactory) {
        self.navigationController = navigationController
        self.viewControllerFactoy = viewControllerFactory
        self.coordinatorFactory = coordinatorFactory
    }
    
    func start() {
        let vc = viewControllerFactoy.makeBaseViewController(with: self)
        navigationController.setViewControllers([vc], animated: true)
    }
    func goToCreationAction() {
        let flow = coordinatorFactory.makeCeationCoordinator()
        flow.start()
    }
}

protocol ClubsFlow: Coordinator {
    func goToCreationAction()
}


protocol ClubCreationFlow: Coordinator {
    func successfullyCreatedNewClub()
}

class BasicClubCreationFlow: ClubCreationFlow {
    
    var navigationController: UINavigationController
    var viewControllerFactory: ClubCreationViewControllerFactory
    
    init(navigationController: UINavigationController, viewControllerFactory: ClubCreationViewControllerFactory) {
        self.navigationController = navigationController
        self.viewControllerFactory = viewControllerFactory
    }
    
    func start() {
        let vc = viewControllerFactory.makeClubCreationViewController()
        navigationController.pushViewController(vc, animated: true)
    }
    
    func successfullyCreatedNewClub() {
        
    }
}

protocol ClubsCoordinatorFactory {
    func makeCeationCoordinator() -> ClubCreationFlow
}

struct BasicClubsCoordinatorFactory: ClubsCoordinatorFactory {
    
    var navigationController: UINavigationController
    var clubCreationViewControllerFactory: ClubCreationViewControllerFactory
    
    func makeCeationCoordinator() -> ClubCreationFlow {
        let flow = BasicClubCreationFlow(navigationController: navigationController, viewControllerFactory: clubCreationViewControllerFactory)
        return flow
    }
}
