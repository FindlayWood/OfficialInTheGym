//
//  File.swift
//  
//
//  Created by Findlay Wood on 25/09/2023.
//

import UIKit

protocol PlayersFlow: Coordinator {
    func addNewPlayer()
    func goToDetail(for model: RemotePlayerModel)
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
        vc.viewModel.selectedPlayer = { [weak self] in self?.goToDetail(for: $0) }
        navigationController.pushViewController(vc, animated: true)
    }
    
    func addNewPlayer() {
        let vc = viewControllerFactory.makeCreatePlayerViewController(with: clubModel)
        navigationController.pushViewController(vc, animated: true)
    }
    
    func goToDetail(for model: RemotePlayerModel) {
        let vc = viewControllerFactory.makePlayerDetailViewController(with: model)
        vc.viewModel.loadTeams()
        vc.viewModel.loadGroups()
        navigationController.pushViewController(vc, animated: true)
    }
}
