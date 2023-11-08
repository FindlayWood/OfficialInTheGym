//
//  File.swift
//  
//
//  Created by Findlay-Personal on 02/06/2023.
//

import UIKit

protocol TeamFlow: Coordinator {
    func addNewTeam()
    func goToTeam(_ model: RemoteTeamModel)
    func goToDefaultLineup(_ model: RemoteTeamModel)
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
        vc.coordinator = self
        navigationController.pushViewController(vc, animated: true)
    }
    
    func addNewTeam() {
        let vc = viewControllerFactory.makeCreateTeamViewController(for: clubModel)
        navigationController.pushViewController(vc, animated: true)
    }
    
    func goToTeam(_ model: RemoteTeamModel) {
        let vc = viewControllerFactory.makeTeamHomeViewController(for: model)
        vc.coordinator = self
        navigationController.pushViewController(vc, animated: true)
    }
    
    func goToDefaultLineup(_ model: RemoteTeamModel) {
        let vc = viewControllerFactory.makeTeamDefaultLineupViewController(for: model)
        navigationController.pushViewController(vc, animated: true)
    }
}
