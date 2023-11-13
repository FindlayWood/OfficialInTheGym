//
//  File.swift
//  
//
//  Created by Findlay-Personal on 14/05/2023.
//

import Foundation

protocol ViewControllerFactory {
    func makeClubHomeViewController(_ model: RemoteClubModel) -> ClubHomeViewController
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
    func makeClubHomeViewController(_ model: RemoteClubModel) -> ClubHomeViewController {
        let vc = ClubHomeViewController(clubModel: model)
        return vc
    }
}
