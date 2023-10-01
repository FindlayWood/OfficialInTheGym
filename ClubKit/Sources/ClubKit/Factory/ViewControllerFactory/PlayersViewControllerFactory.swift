//
//  File.swift
//  
//
//  Created by Findlay Wood on 25/09/2023.
//

import Foundation

protocol PlayersViewControllerFactory {
    func makePlayersViewController(with model: RemoteClubModel) -> PlayersViewController
    func makeCreatePlayerViewController(with model: RemoteClubModel) -> CreatePlayerViewController
}

struct BasicPlayersViewControllerFactory: PlayersViewControllerFactory {
    
    var playerLoader: PlayerLoader
    var teamLoader: TeamLoader
    var creationService: PlayerCreationService
    
    func makePlayersViewController(with model: RemoteClubModel) -> PlayersViewController {
        let vc = PlayersViewController(clubModel: model, playerLoader: playerLoader)
        return vc
    }
    
    func makeCreatePlayerViewController(with model: RemoteClubModel) -> CreatePlayerViewController {
        let viewModel = CreatePlayerViewModel(clubModel: model, loader: playerLoader, teamLoader: teamLoader, creationService: creationService)
        let vc = CreatePlayerViewController(viewModel: viewModel)
        return vc
    }
}
