//
//  File.swift
//  
//
//  Created by Findlay Wood on 20/11/2023.
//

import Foundation

protocol GroupsViewControllerFactory {
    func makeGroupsViewController(for club: RemoteClubModel) -> GroupsListViewController
}

struct BasicGroupsViewControllerFactory: GroupsViewControllerFactory {
    
    var groupLoader: GroupLoader
    
    func makeGroupsViewController(for club: RemoteClubModel) -> GroupsListViewController {
        let viewModel = GroupsListViewModel(groupLoader: groupLoader, clubModel: club)
        let vc = GroupsListViewController(viewModel: viewModel)
        return vc
    }
}
