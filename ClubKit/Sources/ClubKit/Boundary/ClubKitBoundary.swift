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
        
        let clubCreationViewControllerFactory = BasicClubCreationViewControllerFactory(networkService: networkService, clubManager: clubManager)
        
        let clubHomeViewControllerFactory = BasicClubHomeViewControllerFactory()
        
        let client = FirebaseClient(service: networkService)
        
        let playerCreationService = RemotePlayerCreationService(client: client)
        
        let playersViewControllerFactory = BasicPlayersViewControllerFactory(playerLoader: playerLoader,
                                                                             teamLoader: teamLoader,
                                                                             creationService: playerCreationService)
        
        let teamCreationService = RemoteTeamCreationService(client: client)
        let uploadLineupService = RemoteUploadLineupService(client: client)
        let lineupLoader = RemoteLineupLoader(networkService: networkService)
        
        let teamViewControllerFactory = BasicTeamViewControllerFactory(teamLoader: teamLoader,
                                                                       playerLoader: playerLoader,
                                                                       teamCreationService: teamCreationService,
                                                                       lineupUploadService: uploadLineupService,
                                                                       lineupLoader: lineupLoader)
        
        let groupLoader = RemoteGroupLoader(networkService: networkService)
        
        let groupViewControllerFactory = BasicGroupsViewControllerFactory(groupLoader: groupLoader)
        
        let clubHomeCoordinatorFactory = BasicClubHomeCoordinatorFactory(navigationController: navigationController,
                                                                         playersViewControllerFactory: playersViewControllerFactory,
                                                                         teamViewControllerFactory: teamViewControllerFactory,
                                                                         groupsViewControllerFactory: groupViewControllerFactory)
        
        let baseCoordinatorFactory = BasicClubsCoordinatorFactory(navigationController: navigationController,
                                                                  clubCreationViewControllerFactory: clubCreationViewControllerFactory,
                                                                  clubHomeViewControllerFactory: clubHomeViewControllerFactory,
                                                                  clubHomeCoordinatorFactory: clubHomeCoordinatorFactory)
        
        let flow = ClubsCoordinator(navigationController: navigationController,
                                    viewControllerFactory: viewControllerFactory,
                                    coordinatorFactory: baseCoordinatorFactory)
        
        return flow
    }
}
