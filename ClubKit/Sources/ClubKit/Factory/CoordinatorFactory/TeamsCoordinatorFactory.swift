//
//  File.swift
//  
//
//  Created by Findlay Wood on 10/12/2023.
//

import UIKit

protocol TeamsCoordinatorFactory {
    func makePlayersCoordinator(with model: RemoteClubModel) -> PlayersFlow
}

struct BasicTeamsCoordinatorFactory: TeamsCoordinatorFactory {
    
    var navigationController: UINavigationController
    var playersViewControllerFactory: PlayersViewControllerFactory
    
    func makePlayersCoordinator(with model: RemoteClubModel) -> PlayersFlow {
        let flow = BasicPlayersFlow(navigationController: navigationController, viewControllerFactory: playersViewControllerFactory, clubModel: model)
        return flow
    }
}
