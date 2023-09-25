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
    var coordinatorFactory: CoordinatorFactory
    var clubModel: RemoteClubModel
    
    init(navigationController: UINavigationController, viewControllerFactory: ViewControllerFactory, coordinatorFactory: CoordinatorFactory, clubModel: RemoteClubModel) {
        self.navigationController = navigationController
        self.viewControllerFactoy = viewControllerFactory
        self.coordinatorFactory = coordinatorFactory
        self.clubModel = clubModel
    }
    
    func start() {
        let vc = viewControllerFactoy.makeClubHomeViewController(clubModel)
        vc.hidesBottomBarWhenPushed = true
        vc.coordinator = self
        navigationController.pushViewController(vc, animated: true)
    }
    
    func goToTeams() {
        let vc = viewControllerFactoy.makeTeamsViewController(clubModel, flow: self)
        navigationController.pushViewController(vc, animated: true)
    }
    
    func goToTeam(_ model: RemoteTeamModel) {
        let child = coordinatorFactory.makeTeamCoordinator(for: model)
        child.start()
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
    func goToTeam(_ model: RemoteTeamModel)
    func goToPlayers()
    func goToCreatePlayer()
}

class BasicClubHomeFlow: ClubHomeFlow {
    
    var navigationController: UINavigationController
    var viewControllerFactory: ClubHomeViewControllerFactory
    var clubModel: RemoteClubModel
    
    init(navigationController: UINavigationController, viewControllerFactory: ClubHomeViewControllerFactory, clubModel: RemoteClubModel) {
        self.navigationController = navigationController
        self.viewControllerFactory = viewControllerFactory
        self.clubModel = clubModel
    }
    
    func start() {
        let vc = viewControllerFactory.makeClubHomeViewController(with: clubModel)
        vc.coordinator = self
        navigationController.pushViewController(vc, animated: true)
    }
    
    func goToTeams() {
        
    }
    
    func goToTeam(_ model: RemoteTeamModel) {
        
    }
    
    func goToPlayers() {
        let vc = viewControllerFactory.makePlayersViewController(with: clubModel)
        navigationController.pushViewController(vc, animated: true)
    }
    
    func goToCreatePlayer() {
        
    }
}
