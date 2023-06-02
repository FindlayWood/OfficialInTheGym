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
