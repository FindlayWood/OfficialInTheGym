//
//  File.swift
//  
//
//  Created by Findlay Wood on 20/11/2023.
//

import Foundation

protocol GroupsViewControllerFactory {
    func makeGroupsViewController(for club: RemoteClubModel) -> GroupsListViewController
    func makeCreateGroupViewController(for club: RemoteClubModel) -> CreateGroupViewController
    func makePlayersViewController(for club: RemoteClubModel) -> PlayersViewController
}

struct BasicGroupsViewControllerFactory: GroupsViewControllerFactory {
    
    var groupLoader: GroupLoader
    var playerLoader: PlayerLoader
    var groupCreationService: GroupCreationService
    var imageCache: ImageCache
    
    func makeGroupsViewController(for club: RemoteClubModel) -> GroupsListViewController {
        let viewModel = GroupsListViewModel(groupLoader: groupLoader, clubModel: club)
        let vc = GroupsListViewController(viewModel: viewModel)
        return vc
    }
    
    func makeCreateGroupViewController(for club: RemoteClubModel) -> CreateGroupViewController {
        let viewModel = CreateGroupViewModel(clubModel: club, creationService: groupCreationService, imageCache: imageCache)
        let vc = CreateGroupViewController(viewModel: viewModel)
        return vc
    }
    
    func makePlayersViewController(for club: RemoteClubModel) -> PlayersViewController {
        let viewModel = PlayersViewModel(clubModel: club, playerLoader: playerLoader, selectable: true, imageCache: imageCache)
        let vc = PlayersViewController(viewModel: viewModel)
        return vc
    }
}
