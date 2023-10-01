//
//  File.swift
//  
//
//  Created by Findlay Wood on 30/09/2023.
//

import Foundation

protocol TeamViewControllerFactory {
    func makeTeamsViewController(for club: RemoteClubModel) -> TeamsViewController
}

struct BasicTeamViewControllerFactory: TeamViewControllerFactory {
    
    var teamLoader: TeamLoader
    
    func makeTeamsViewController(for club: RemoteClubModel) -> TeamsViewController {
        let viewModel = TeamsViewModel(clubModel: club, teamLoader: teamLoader)
        let vc = TeamsViewController(viewModel: viewModel)
        return vc
    }
}
