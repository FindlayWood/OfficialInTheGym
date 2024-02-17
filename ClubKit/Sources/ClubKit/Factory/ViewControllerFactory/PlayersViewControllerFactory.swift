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
    func makePlayerDetailViewController(with model: RemotePlayerModel, in clubModel: RemoteClubModel) -> PlayerDetailViewController
    func makeLinkPlayerViewController(in club: RemoteClubModel, for player: RemotePlayerModel) -> LinkPlayerViewController
}

struct BasicPlayersViewControllerFactory: PlayersViewControllerFactory {
    
    var playerLoader: PlayerLoader
    var groupLoader: GroupLoader
    var teamLoader: TeamLoader
    var creationService: PlayerCreationService
    var qrScannerService: QRScannerService
    var linkPlayerService: LinkPlayerService
    var imageCache: ImageCache
    
    func makePlayersViewController(with model: RemoteClubModel) -> PlayersViewController {
        let viewModel = PlayersViewModel(clubModel: model, playerLoader: playerLoader, imageCache: imageCache)
        let vc = PlayersViewController(viewModel: viewModel)
        return vc
    }
    
    func makeCreatePlayerViewController(with model: RemoteClubModel) -> CreatePlayerViewController {
        let viewModel = CreatePlayerViewModel(clubModel: model, loader: playerLoader, teamLoader: teamLoader, creationService: creationService)
        let vc = CreatePlayerViewController(viewModel: viewModel)
        return vc
    }
    
    func makePlayerDetailViewController(with model: RemotePlayerModel, in clubModel: RemoteClubModel) -> PlayerDetailViewController {
        let viewModel = PlayerDetailViewModel(playerModel: model, clubModel: clubModel, groupLoader: groupLoader, teamLoader: teamLoader, imageCache: imageCache)
        let vc = PlayerDetailViewController(viewModel: viewModel)
        return vc
    }
    
    func makeLinkPlayerViewController(in club: RemoteClubModel, for player: RemotePlayerModel) -> LinkPlayerViewController {
        let viewModel = LinkPlayerViewModel(scannerService: qrScannerService, clubModel: club, loader: playerLoader, playerModel: player, linkService: linkPlayerService)
        let vc = LinkPlayerViewController(viewModel: viewModel)
        return vc
    }
}
