//
//  File.swift
//  
//
//  Created by Findlay Wood on 25/11/2023.
//

import Foundation

protocol StaffViewControllerFactory {
    func makeStaffViewController(with model: RemoteClubModel) -> StaffListViewController
}

struct BasicStaffViewControllerFactory: StaffViewControllerFactory {
    
    var staffLoader: StaffLoader
    
    func makeStaffViewController(with model: RemoteClubModel) -> StaffListViewController {
        let viewModel = StaffListViewModel(clubModel: model, staffLoader: staffLoader)
        let vc = StaffListViewController(viewModel: viewModel)
        return vc
    }

}
