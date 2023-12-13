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
    func goToPlayers(_ model: RemoteTeamModel)
    func showPlayersList(for team: RemoteTeamModel, excluding: [RemotePlayerModel], selectedAction: @escaping (RemotePlayerModel) -> ())
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
        vc.coordinator = self
        navigationController.pushViewController(vc, animated: true)
    }
    
    func goToPlayers(_ model: RemoteTeamModel) {
        let vc = viewControllerFactory.makePlayersViewController(for: clubModel)
        vc.viewModel.loadFromTeam(with: model.id)
        vc.viewModel.selectedPlayer = { [weak self] in self?.goToDetail(for: $0) }
        navigationController.pushViewController(vc, animated: true)
    }
    func goToDetail(for model: RemotePlayerModel) {
        let vc = viewControllerFactory.makePlayerDetailViewController(with: model)
        navigationController.pushViewController(vc, animated: true)
    }
    
    func showPlayersList(for team: RemoteTeamModel, excluding: [RemotePlayerModel], selectedAction: @escaping (RemotePlayerModel) -> ()) {
        let vc = viewControllerFactory.makePlayersViewController(for: clubModel)
        vc.viewModel.excludedPlayers = excluding
        vc.viewModel.loadFromTeam(with: team.id)
        vc.viewModel.selectedPlayer = selectedAction
        navigationController.present(vc, animated: true)
    }
}
