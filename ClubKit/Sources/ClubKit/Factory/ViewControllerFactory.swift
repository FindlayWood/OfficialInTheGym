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
    var userService: CurrentUserService
    let imageCache: ImageCache
    
    init(clubManager: ClubManager, userService: CurrentUserService, imageCache: ImageCache) {
        self.clubManager = clubManager
        self.userService = userService
        self.imageCache = imageCache
    }
    
    func makeBaseViewController(with flow: ClubsFlow) -> ClubsViewController {
        let viewModel = ClubsViewModel(clubManager: clubManager, flow: flow, imageCache: imageCache)
        let vc = ClubsViewController(viewModel: viewModel, coordinator: flow)
        return vc
    }
    
    func makeQRViewController() -> AddPlayerQRViewController {
        let viewModel = AddPlayerQRViewModel(userService: userService)
        let vc = AddPlayerQRViewController(viewModel: viewModel)
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
