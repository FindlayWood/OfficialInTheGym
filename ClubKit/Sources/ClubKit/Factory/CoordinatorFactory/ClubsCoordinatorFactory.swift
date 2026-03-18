//
//  File.swift
//  
//
//  Created by Findlay Wood on 21/09/2023.
//

import UIKit

protocol ClubsCoordinatorFactory {
    func makeCeationCoordinator() -> ClubCreationFlow
    func makeClubHomeCoordinator(with model: RemoteClubModel) -> ClubHomeFlow
}

struct BasicClubsCoordinatorFactory: ClubsCoordinatorFactory {
    
    var navigationController: UINavigationController
    var clubCreationViewControllerFactory: ClubCreationViewControllerFactory
    var clubHomeViewControllerFactory: ClubHomeViewControllerFactory
    var clubHomeCoordinatorFactory: ClubHomeCoordinatorFactory
    
    func makeCeationCoordinator() -> ClubCreationFlow {
        let flow = BasicClubCreationFlow(navigationController: navigationController, viewControllerFactory: clubCreationViewControllerFactory)
        return flow
    }
    
    func makeClubHomeCoordinator(with model: RemoteClubModel) -> ClubHomeFlow {
        let flow = BasicClubHomeFlow(navigationController: navigationController, viewControllerFactory: clubHomeViewControllerFactory, clubHomeCoordinatorFactory: clubHomeCoordinatorFactory, clubModel: model)
        return flow
    }
}
