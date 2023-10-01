//
//  File.swift
//  
//
//  Created by Findlay Wood on 25/09/2023.
//

import UIKit

protocol ClubHomeCoordinatorFactory {
    func makePlayersCoordinator(with model: RemoteClubModel) -> PlayersFlow
    func makeTeamsCoordinator(with model: RemoteClubModel) -> TeamFlow
}

struct BasicClubHomeCoordinatorFactory: ClubHomeCoordinatorFactory {
    
    var navigationController: UINavigationController
    var playersViewControllerFactory: PlayersViewControllerFactory
    var teamViewControllerFactory: TeamViewControllerFactory
    
    func makePlayersCoordinator(with model: RemoteClubModel) -> PlayersFlow {
        let flow = BasicPlayersFlow(navigationController: navigationController, viewControllerFactory: playersViewControllerFactory, clubModel: model)
        return flow
    }
    
    func makeTeamsCoordinator(with model: RemoteClubModel) -> TeamFlow {
        let flow = BasicTeamFlow(navigationController: navigationController, viewControllerFactory: teamViewControllerFactory, clubModel: model)
        return flow
    }
}
