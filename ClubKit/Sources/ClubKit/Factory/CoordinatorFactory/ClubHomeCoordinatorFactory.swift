//
//  File.swift
//  
//
//  Created by Findlay Wood on 25/09/2023.
//

import UIKit

protocol ClubHomeCoordinatorFactory {
    func makePlayersCoordinator(with model: RemoteClubModel) -> PlayersFlow
}

struct BasicClubHomeCoordinatorFactory: ClubHomeCoordinatorFactory {
    
    var navigationController: UINavigationController
    var playersViewControllerFactory: PlayersViewControllerFactory
    
    func makePlayersCoordinator(with model: RemoteClubModel) -> PlayersFlow {
        let flow = BasicPlayersFlow(navigationController: navigationController, viewControllerFactory: playersViewControllerFactory, clubModel: model)
        return flow
    }
}
