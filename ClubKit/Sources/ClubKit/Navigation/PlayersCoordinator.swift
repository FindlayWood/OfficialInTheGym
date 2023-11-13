//
//  File.swift
//  
//
//  Created by Findlay Wood on 25/09/2023.
//

import UIKit

protocol PlayersFlow: Coordinator {
    func addNewPlayer()
}


class BasicPlayersFlow: PlayersFlow {
    
    var navigationController: UINavigationController
    var viewControllerFactory: PlayersViewControllerFactory
    var clubModel: RemoteClubModel
    
    init(navigationController: UINavigationController, viewControllerFactory: PlayersViewControllerFactory, clubModel: RemoteClubModel) {
        self.navigationController = navigationController
        self.viewControllerFactory = viewControllerFactory
        self.clubModel = clubModel
    }
    
    func start() {
        let vc = viewControllerFactory.makePlayersViewController(with: clubModel)
        vc.coordinator = self
        vc.viewModel.loadFromClub()
        navigationController.pushViewController(vc, animated: true)
    }
    
    func addNewPlayer() {
        let vc = viewControllerFactory.makeCreatePlayerViewController(with: clubModel)
        navigationController.pushViewController(vc, animated: true)
    }
}
