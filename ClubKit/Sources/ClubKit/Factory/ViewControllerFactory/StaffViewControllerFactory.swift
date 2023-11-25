//
//  File.swift
//  
//
//  Created by Findlay Wood on 25/11/2023.
//

import Foundation

protocol StaffViewControllerFactory {
    func makeStaffViewController(with model: RemoteClubModel) -> StaffListViewController
    func makeCreateStaffViewController(with model: RemoteClubModel) -> CreateStaffViewController
}

struct BasicStaffViewControllerFactory: StaffViewControllerFactory {
    
    var staffLoader: StaffLoader
    var teamLoader: TeamLoader
    var creationservice: StaffCreationService
    
    func makeStaffViewController(with model: RemoteClubModel) -> StaffListViewController {
        let viewModel = StaffListViewModel(clubModel: model, staffLoader: staffLoader)
        let vc = StaffListViewController(viewModel: viewModel)
        return vc
    }
    func makeCreateStaffViewController(with model: RemoteClubModel) -> CreateStaffViewController {
        let viewModel = CreateStaffViewModel(clubModel: model, teamLoader: teamLoader, creationService: creationservice)
        let vc = CreateStaffViewController(viewModel: viewModel)
        return vc
    }
}
