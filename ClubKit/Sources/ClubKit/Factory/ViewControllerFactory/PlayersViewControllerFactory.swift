//
//  File.swift
//  
//
//  Created by Findlay Wood on 25/09/2023.
//

import Foundation

protocol PlayersViewControllerFactory {
    func makePlayersViewController(with model: RemoteClubModel) -> PlayersViewController
}

struct BasicPlayersViewControllerFactory: PlayersViewControllerFactory {
    
    var playerLoader: PlayerLoader
    
    func makePlayersViewController(with model: RemoteClubModel) -> PlayersViewController {
        let vc = PlayersViewController(clubModel: model, playerLoader: playerLoader)
        return vc
    }
}
