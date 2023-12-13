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
    func makePlayerDetailViewController(with model: RemotePlayerModel) -> PlayerDetailViewController
}

struct BasicPlayersViewControllerFactory: PlayersViewControllerFactory {
    
    var playerLoader: PlayerLoader
    var groupLoader: GroupLoader
    var teamLoader: TeamLoader
    var creationService: PlayerCreationService
    
    func makePlayersViewController(with model: RemoteClubModel) -> PlayersViewController {
        let viewModel = PlayersViewModel(clubModel: model, playerLoader: playerLoader)
        let vc = PlayersViewController(viewModel: viewModel)
        return vc
    }
    
    func makeCreatePlayerViewController(with model: RemoteClubModel) -> CreatePlayerViewController {
        let viewModel = CreatePlayerViewModel(clubModel: model, loader: playerLoader, teamLoader: teamLoader, creationService: creationService)
        let vc = CreatePlayerViewController(viewModel: viewModel)
        return vc
    }
    
    func makePlayerDetailViewController(with model: RemotePlayerModel) -> PlayerDetailViewController {
        let viewModel = PlayerDetailViewModel(playerModel: model, groupLoader: groupLoader, teamLoader: teamLoader)
        let vc = PlayerDetailViewController(viewModel: viewModel)
        return vc
    }
}
