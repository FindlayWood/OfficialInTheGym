//
//  File.swift
//  
//
//  Created by Findlay-Personal on 14/05/2023.
//

import UIKit

class ClubHomeCoordinator: ClubHomeFlow {
    
    var navigationController: UINavigationController
    var viewControllerFactoy: ViewControllerFactory
    var clubModel: RemoteClubModel
    
    init(navigationController: UINavigationController, viewControllerFactory: ViewControllerFactory, clubModel: RemoteClubModel) {
        self.navigationController = navigationController
        self.viewControllerFactoy = viewControllerFactory
        self.clubModel = clubModel
    }
    
    func start() {
        let vc = viewControllerFactoy.makeClubHomeViewController(clubModel)
        vc.hidesBottomBarWhenPushed = true
        vc.coordinator = self
        navigationController.pushViewController(vc, animated: true)
    }
    
    func goToTeams() {
        let vc = viewControllerFactoy.makeTeamsHomeViewController(clubModel)
        navigationController.pushViewController(vc, animated: true)
    }
    
    func goToPlayers() {
        let vc = viewControllerFactoy.makePlayersViewController(clubModel)
        vc.coordinator = self
        navigationController.pushViewController(vc, animated: true)
    }
    
    func goToCreatePlayer() {
        let vc = viewControllerFactoy.makeCreatePlayerViewController(clubModel)
        navigationController.pushViewController(vc, animated: true)
    }
}

protocol ClubHomeFlow: Coordinator {
    func goToTeams()
    func goToPlayers()
    func goToCreatePlayer()
}
