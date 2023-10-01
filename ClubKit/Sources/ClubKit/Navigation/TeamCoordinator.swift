//
//  File.swift
//  
//
//  Created by Findlay-Personal on 02/06/2023.
//

import UIKit

class TeamCoordinator: TeamFlow {
     
    var navigationController: UINavigationController
    var viewControllerFactory: ViewControllerFactory
    var teamModel: RemoteTeamModel
    
    init(navigationController: UINavigationController, viewControllerFactory: ViewControllerFactory, teamModel: RemoteTeamModel) {
        self.navigationController = navigationController
        self.viewControllerFactory = viewControllerFactory
        self.teamModel = teamModel
    }
    
    func start() {
        let vc = viewControllerFactory.makeTeamHomeViewController(teamModel)
        navigationController.pushViewController(vc, animated: true)
    }
    
}

protocol TeamFlow: Coordinator {
    
}

class BasicTeamFlow: TeamFlow {

    var navigationController: UINavigationController
    var viewControllerFactory: TeamViewControllerFactory
    var clubModel: RemoteClubModel
    
    init(navigationController: UINavigationController, viewControllerFactory: TeamViewControllerFactory, clubModel: RemoteClubModel) {
        self.navigationController = navigationController
        self.viewControllerFactory = viewControllerFactory
        self.clubModel = clubModel
    }
    
    func start() {
        let vc = viewControllerFactory.makeTeamsViewController(for: clubModel)
        navigationController.pushViewController(vc, animated: true)
    }
}
