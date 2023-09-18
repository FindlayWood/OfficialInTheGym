//
//  File.swift
//  
//
//  Created by Findlay-Personal on 14/05/2023.
//

import Foundation

protocol ViewControllerFactory {
//    func makeClubsViewController(flow: ClubsFlow) -> ClubsViewController
    func makeClubCreationViewController() -> ClubCreationViewController
    func makeClubHomeViewController(_ model: RemoteClubModel) -> ClubHomeViewController
    func makeTeamsViewController(_ model: RemoteClubModel, flow: ClubHomeFlow) -> TeamsViewController
    func makeTeamHomeViewController(_ model: RemoteTeamModel) -> TeamHomeViewController
    func makePlayersViewController(_ model: RemoteClubModel) -> PlayersViewController
    func makeCreatePlayerViewController(_ model: RemoteClubModel) -> CreatePlayerViewController
}

class BaseViewControllerFactory {
    
    var clubManager: ClubManager
    
    init(clubManager: ClubManager) {
        self.clubManager = clubManager
    }
    
    func makeBaseViewController(with flow: ClubsFlow) -> ClubsViewController {
        let viewModel = ClubsViewModel(clubManager: clubManager, flow: flow)
        let vc = ClubsViewController(viewModel: viewModel, coordinator: flow)
        return vc
    }
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
    
//    func makeClubsViewController(flow: ClubsFlow) -> ClubsViewController {
//        let vc = ClubsViewController(clubManager: clubManager, coordinator: flow)
//        return vc
//    }
    
    func makeClubCreationViewController() -> ClubCreationViewController {
        let vc = ClubCreationViewController()
        return vc
    }
    
    func makeClubHomeViewController(_ model: RemoteClubModel) -> ClubHomeViewController {
        let vc = ClubHomeViewController(clubModel: model)
        return vc
    }
    
    func makeTeamsViewController(_ model: RemoteClubModel, flow: ClubHomeFlow) -> TeamsViewController {
        let vc = TeamsViewController(clubModel: model, teamLoader: teamLoader, coordinator: flow)
        return vc
    }
    
    func makeTeamHomeViewController(_ model: RemoteTeamModel) -> TeamHomeViewController {
        let vc = TeamHomeViewController()
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

protocol ClubCreationViewControllerFactory {
    func makeClubCreationViewController() -> ClubCreationViewController
}

struct BasicClubCreationViewControllerFactory: ClubCreationViewControllerFactory {
    
    var networkService: NetworkService
    
    func makeClubCreationViewController() -> ClubCreationViewController {
        let client = FirebaseClient(service: networkService)
        let creationService = RemoteCreationService(client: client)
        let viewModel = ClubCreationViewModel(service: creationService)
        let vc = ClubCreationViewController(viewModel: viewModel)
        return vc
    }
}
