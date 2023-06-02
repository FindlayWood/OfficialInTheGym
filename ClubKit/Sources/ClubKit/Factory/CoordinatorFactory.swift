//
//  File.swift
//  
//
//  Created by Findlay-Personal on 10/05/2023.
//

import UIKit

protocol CoordinatorFactory {
    var navigationController: UINavigationController { get }
    var viewControllerFactory: ViewControllerFactory { get }
    func makeClubsCoordinator() -> ClubsFlow
    func makeClubHomeCoordinator(with model: RemoteClubModel) -> ClubHomeFlow
    func makeTeamCoordinator(for model: RemoteTeamModel) -> TeamFlow
}

class RegularCoordinatorFactory: CoordinatorFactory {
    var navigationController: UINavigationController
    var viewControllerFactory: ViewControllerFactory
    
    init(navigationController: UINavigationController, viewControllerFactory: ViewControllerFactory) {
        self.navigationController = navigationController
        self.viewControllerFactory = viewControllerFactory
    }
    
    func makeClubsCoordinator() -> ClubsFlow {
        let child = ClubsCoordinator(navigationController: navigationController, viewControllerFactory: viewControllerFactory, coordinatorFactory: self)
        return child
    }
    
    func makeClubHomeCoordinator(with model: RemoteClubModel) -> ClubHomeFlow {
        let child = ClubHomeCoordinator(navigationController: navigationController, viewControllerFactory: viewControllerFactory, coordinatorFactory: self, clubModel: model)
        return child
    }
    
    func makeTeamCoordinator(for model: RemoteTeamModel) -> TeamFlow {
        let child = TeamCoordinator(navigationController: navigationController, viewControllerFactory: viewControllerFactory, teamModel: model)
        return child
    }
}
