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
    func goToClubAction(_ clubModel: RemoteClubModel) {
        let flow = coordinatorFactory.makeClubHomeCoordinator(with: clubModel)
        flow.start()
    }
}

protocol ClubsFlow: Coordinator {
    func goToCreationAction()
    func goToClubAction(_ clubModel: RemoteClubModel)
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
        navigationController.present(vc, animated: true)
    }
    
    func successfullyCreatedNewClub() {
        
    }
}

class BasicClubHomeFlow: ClubHomeFlow {
    
    var navigationController: UINavigationController
    var viewControllerFactory: ClubHomeViewControllerFactory
    var clubModel: RemoteClubModel
    
    init(navigationController: UINavigationController, viewControllerFactory: ClubHomeViewControllerFactory, clubModel: RemoteClubModel) {
        self.navigationController = navigationController
        self.viewControllerFactory = viewControllerFactory
        self.clubModel = clubModel
    }
    
    func start() {
        let vc = viewControllerFactory.makeClubHomeViewController(with: clubModel)
        navigationController.pushViewController(vc, animated: true)
    }
    
    func goToTeams() {
        
    }
    
    func goToTeam(_ model: RemoteTeamModel) {
        
    }
    
    func goToPlayers() {
        
    }
    
    func goToCreatePlayer() {
        
    }
}

protocol ClubsCoordinatorFactory {
    func makeCeationCoordinator() -> ClubCreationFlow
    func makeClubHomeCoordinator(with model: RemoteClubModel) -> ClubHomeFlow
}

struct BasicClubsCoordinatorFactory: ClubsCoordinatorFactory {
    
    var navigationController: UINavigationController
    var clubCreationViewControllerFactory: ClubCreationViewControllerFactory
    var clubHomeViewControllerFactory: ClubHomeViewControllerFactory
    
    func makeCeationCoordinator() -> ClubCreationFlow {
        let flow = BasicClubCreationFlow(navigationController: navigationController, viewControllerFactory: clubCreationViewControllerFactory)
        return flow
    }
    
    func makeClubHomeCoordinator(with model: RemoteClubModel) -> ClubHomeFlow {
        let flow = BasicClubHomeFlow(navigationController: navigationController, viewControllerFactory: clubHomeViewControllerFactory, clubModel: model)
        return flow
    }
}
