//
//  File.swift
//  
//
//  Created by Findlay Wood on 21/09/2023.
//

import Foundation

protocol ClubHomeViewControllerFactory {
    func makeClubHomeViewController(with model: RemoteClubModel) -> ClubHomeViewController
    func makePlayersViewController(with model: RemoteClubModel) -> PlayersViewController
}

struct BasicClubHomeViewControllerFactory: ClubHomeViewControllerFactory {
    
    var playerLoader: PlayerLoader
    
    func makeClubHomeViewController(with model: RemoteClubModel) -> ClubHomeViewController {
        let vc = ClubHomeViewController(clubModel: model)
        return vc
    }
    
    func makePlayersViewController(with model: RemoteClubModel) -> PlayersViewController {
        let vc = PlayersViewController(clubModel: model, playerLoader: playerLoader)
        return vc
    }
}
