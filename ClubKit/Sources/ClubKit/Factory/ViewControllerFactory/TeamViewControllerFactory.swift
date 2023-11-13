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
    func makeTeamDefaultLineupViewController(for team: RemoteTeamModel) -> TeamDefaultLineupViewController
    func makePlayersViewController(for club: RemoteClubModel) -> PlayersViewController
}

struct BasicTeamViewControllerFactory: TeamViewControllerFactory {
    
    var teamLoader: TeamLoader
    var playerLoader: PlayerLoader
    var teamCreationService: TeamCreationService
    var lineupUploadService: UploadLineupService
    var lineupLoader: LineupLoader
    
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
    
    func makeTeamDefaultLineupViewController(for team: RemoteTeamModel) -> TeamDefaultLineupViewController {
        let viewModel = TeamDefaultLineupViewModel(team: team, lineupLoader: lineupLoader, playerLoader: playerLoader, lineupUploadService: lineupUploadService)
        let vc = TeamDefaultLineupViewController(viewModel: viewModel)
        return vc
    }
    
    func makePlayersViewController(for club: RemoteClubModel) -> PlayersViewController {
        let viewModel = PlayersViewModel(clubModel: club, playerLoader: playerLoader)
        let vc = PlayersViewController(viewModel: viewModel)
        return vc
    }
}
