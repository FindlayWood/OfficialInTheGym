//
//  File.swift
//  
//
//  Created by Findlay-Personal on 14/05/2023.
//

import Foundation

protocol ViewControllerFactory {
    func makeClubsViewController(flow: ClubsFlow) -> ClubsViewController
    func makeClubCreationViewController() -> ClubCreationViewController
    func makeClubHomeViewController(_ model: RemoteClubModel) -> ClubHomeViewController
    func makeTeamsHomeViewController(_ model: RemoteClubModel) -> TeamsViewController
    func makePlayersViewController(_ model: RemoteClubModel) -> PlayersViewController
    func makeCreatePlayerViewController(_ model: RemoteClubModel) -> CreatePlayerViewController
}

class RegularViewControllerFactory: ViewControllerFactory {
    var clubManager: ClubManager
    var teamLoader: TeamLoader
    var playerLoader: PlayerLoader
    
    init(clubManager: ClubManager, teamLoader: TeamLoader, playerLoader: PlayerLoader) {
        self.clubManager = clubManager
        self.teamLoader = teamLoader
        self.playerLoader = playerLoader
    }
    
    func makeClubsViewController(flow: ClubsFlow) -> ClubsViewController {
        let vc = ClubsViewController(clubManager: clubManager, coordinator: flow)
        return vc
    }
    
    func makeClubCreationViewController() -> ClubCreationViewController {
        let vc = ClubCreationViewController()
        return vc
    }
    
    func makeClubHomeViewController(_ model: RemoteClubModel) -> ClubHomeViewController {
        let vc = ClubHomeViewController(clubModel: model)
        return vc
    }
    
    func makeTeamsHomeViewController(_ model: RemoteClubModel) -> TeamsViewController {
        let vc = TeamsViewController(clubModel: model, teamLoader: teamLoader)
        return vc
    }
    
    func makePlayersViewController(_ model: RemoteClubModel) -> PlayersViewController {
        let vc = PlayersViewController(clubModel: model, playerLoader: playerLoader)
        return vc
    }
    
    func makeCreatePlayerViewController(_ model: RemoteClubModel) -> CreatePlayerViewController {
        let vc = CreatePlayerViewController(clubModel: model, loader: playerLoader, teamLoader: teamLoader)
        return vc
    }
}
