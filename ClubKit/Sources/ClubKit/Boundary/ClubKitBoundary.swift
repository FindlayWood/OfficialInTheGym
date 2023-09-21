//
//  File.swift
//  
//
//  Created by Findlay-Personal on 14/05/2023.
//

import UIKit

public class ClubKitBoundary {
    
    private lazy var playerLoader = RemotePlayerLoader(networkService: networkService)
    private lazy var teamLoader = RemoteTeamLoader(networkService: networkService)
    private lazy var viewControllerFactory = RegularViewControllerFactory(clubManager: clubManager, teamLoader: teamLoader, playerLoader: playerLoader)
    private lazy var coordinatorFactory = RegularCoordinatorFactory(navigationController: navigationController, viewControllerFactory: viewControllerFactory)
    private lazy var clubLoader = RemoteClubLoader(networkService: networkService, userService: userService)
    private lazy var clubManager = RemoteClubManager(clubLoader: clubLoader)
    var networkService: NetworkService
    var userService: CurrentUserService
    var navigationController: UINavigationController
    
    public init(navigationController: UINavigationController, networkService: NetworkService, userService: CurrentUserService) {
        self.navigationController = navigationController
        self.networkService = networkService
        self.userService = userService
    }
    
    public func compose() {
        let base = makeBase()
        base.start()
    }
    
    func makeBase() -> ClubsFlow {
        
        let viewControllerFactory = BaseViewControllerFactory(clubManager: clubManager)
        
        let clubCreationViewControllerFactory = BasicClubCreationViewControllerFactory(networkService: networkService)
        
        let clubHomeViewControllerFactory = BasicClubHomeViewControllerFactory()
        
        let baseCoordinatorFactory = BasicClubsCoordinatorFactory(navigationController: navigationController,
                                                                  clubCreationViewControllerFactory: clubCreationViewControllerFactory,
                                                                  clubHomeViewControllerFactory: clubHomeViewControllerFactory)
        
        let flow = ClubsCoordinator(navigationController: navigationController,
                                    viewControllerFactory: viewControllerFactory,
                                    coordinatorFactory: baseCoordinatorFactory)
        
        return flow
    }
}
