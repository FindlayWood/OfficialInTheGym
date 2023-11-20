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
    func makeGroupsCoordinator(with model: RemoteClubModel) -> GroupFlow
}

struct BasicClubHomeCoordinatorFactory: ClubHomeCoordinatorFactory {
    
    var navigationController: UINavigationController
    var playersViewControllerFactory: PlayersViewControllerFactory
    var teamViewControllerFactory: TeamViewControllerFactory
    var groupsViewControllerFactory: GroupsViewControllerFactory
    
    func makePlayersCoordinator(with model: RemoteClubModel) -> PlayersFlow {
        let flow = BasicPlayersFlow(navigationController: navigationController, viewControllerFactory: playersViewControllerFactory, clubModel: model)
        return flow
    }
    
    func makeTeamsCoordinator(with model: RemoteClubModel) -> TeamFlow {
        let flow = BasicTeamFlow(navigationController: navigationController, viewControllerFactory: teamViewControllerFactory, clubModel: model)
        return flow
    }
    
    func makeGroupsCoordinator(with model: RemoteClubModel) -> GroupFlow {
        let flow = BasicGroupFlow(navigationController: navigationController, viewControllerFactory: groupsViewControllerFactory, clubModel: model)
        return flow
    }
}
