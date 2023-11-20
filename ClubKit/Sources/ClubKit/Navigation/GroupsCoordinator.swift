//
//  File.swift
//  
//
//  Created by Findlay Wood on 20/11/2023.
//

import UIKit

protocol GroupFlow: Coordinator {
    func createNewGroup()
    func selectPlayersForNewGroup(_ selectedAction: @escaping ([RemotePlayerModel]) -> ())
}

class BasicGroupFlow: GroupFlow {

    var navigationController: UINavigationController
    var viewControllerFactory: GroupsViewControllerFactory
    var clubModel: RemoteClubModel
    
    init(navigationController: UINavigationController, viewControllerFactory: GroupsViewControllerFactory, clubModel: RemoteClubModel) {
        self.navigationController = navigationController
        self.viewControllerFactory = viewControllerFactory
        self.clubModel = clubModel
    }
    
    func start() {
        let vc = viewControllerFactory.makeGroupsViewController(for: clubModel)
        vc.coordinator = self
        navigationController.pushViewController(vc, animated: true)
    }
    
    func createNewGroup() {
        let vc = viewControllerFactory.makeCreateGroupViewController(for: clubModel)
        vc.coordinator = self
        navigationController.pushViewController(vc, animated: true)
    }
    
    func selectPlayersForNewGroup(_ selectedAction: @escaping ([RemotePlayerModel]) -> ()) {
        let vc = viewControllerFactory.makePlayersViewController(for: clubModel)
        vc.viewModel.loadFromClub()
        vc.viewModel.selectedPlayersConfirmed = selectedAction
        navigationController.present(vc, animated: true)
    }
}
