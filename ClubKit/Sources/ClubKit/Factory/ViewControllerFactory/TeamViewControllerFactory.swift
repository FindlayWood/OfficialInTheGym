//
//  File.swift
//  
//
//  Created by Findlay Wood on 30/09/2023.
//

import Foundation

protocol TeamViewControllerFactory {
    func makeTeamsViewController(for club: RemoteClubModel) -> TeamsViewController
    func makeCreateTeamViewController(for club: RemoteClubModel) -> CreateTeamViewController
    func makeTeamHomeViewController(for team: RemoteTeamModel) -> TeamHomeViewController
}

struct BasicTeamViewControllerFactory: TeamViewControllerFactory {
    
    var teamLoader: TeamLoader
    var playerLoader: PlayerLoader
    var teamCreationService: TeamCreationService
    
    func makeTeamsViewController(for club: RemoteClubModel) -> TeamsViewController {
        let viewModel = TeamsViewModel(clubModel: club, teamLoader: teamLoader)
        let vc = TeamsViewController(viewModel: viewModel)
        return vc
    }
    
    func makeCreateTeamViewController(for club: RemoteClubModel) -> CreateTeamViewController {
        let viewModel = CreateTeamViewModel(playerLoader: playerLoader, teamCreationService: teamCreationService, clubModel: club)
        let vc = CreateTeamViewController(viewModel: viewModel)
        return vc
    }
    
    func makeTeamHomeViewController(for team: RemoteTeamModel) -> TeamHomeViewController {
        let viewModel = TeamHomeViewModel(team: team)
        let vc = TeamHomeViewController(viewModel: viewModel)
        return vc
    }
}
