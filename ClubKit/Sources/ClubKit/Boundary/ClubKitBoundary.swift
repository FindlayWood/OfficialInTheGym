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
    var storageService: StorageService
    var userService: CurrentUserService
    var navigationController: UINavigationController
    
    public init(navigationController: UINavigationController, networkService: NetworkService, storageService: StorageService, userService: CurrentUserService) {
        self.navigationController = navigationController
        self.networkService = networkService
        self.storageService = storageService
        self.userService = userService
    }
    
    public func compose() {
        let base = makeBase()
        base.start()
    }
    
    func makeBase() -> ClubsFlow {
        
        let imageCache = FirebaseImageCache(storageService: storageService)
        
        let viewControllerFactory = BaseViewControllerFactory(clubManager: clubManager, userService: userService, imageCache: imageCache)
        
        let clubCreationViewControllerFactory = BasicClubCreationViewControllerFactory(networkService: networkService, clubManager: clubManager)
        
        let scannerService = RemoteQRScannerService(networkService: networkService)
        
        let linkPlayerService = RemoteLinkPlayerService(networkService: networkService)
        
        let client = FirebaseClient(service: networkService)
        
        let playerCreationService = RemotePlayerCreationService(client: client)
        
        let groupLoader = RemoteGroupLoader(networkService: networkService)
        let groupCreationService = RemoteGroupCreationService(client: client)
        
        let clubHomeViewControllerFactory = BasicClubHomeViewControllerFactory(qrScannerService: scannerService,
                                                                               playerLoader: playerLoader,
                                                                               teamLoader: teamLoader,
                                                                               creationService: playerCreationService,
                                                                               imageCache: imageCache)
        
        
        let playersViewControllerFactory = BasicPlayersViewControllerFactory(playerLoader: playerLoader,
                                                                             groupLoader: groupLoader,
                                                                             teamLoader: teamLoader,
                                                                             creationService: playerCreationService,
                                                                             qrScannerService: scannerService,
                                                                             linkPlayerService: linkPlayerService,
                                                                             imageCache: imageCache)
        
        let teamCreationService = RemoteTeamCreationService(client: client)
        let uploadLineupService = RemoteUploadLineupService(client: client)
        let lineupLoader = RemoteLineupLoader(networkService: networkService)
        
        let teamViewControllerFactory = BasicTeamViewControllerFactory(groupLoader: groupLoader,
                                                                       teamLoader: teamLoader,
                                                                       playerLoader: playerLoader,
                                                                       teamCreationService: teamCreationService,
                                                                       lineupUploadService: uploadLineupService,
                                                                       lineupLoader: lineupLoader,
                                                                       imageCache: imageCache)
        
        
        let groupViewControllerFactory = BasicGroupsViewControllerFactory(groupLoader: groupLoader,
                                                                          playerLoader: playerLoader,
                                                                          groupCreationService: groupCreationService,
                                                                          imageCache: imageCache)
        
        let staffLoader = RemoteStaffLoader(networkService: networkService)
        let staffCreationservice = RemoteStaffCreationService(client: client)
        let staffViewControllerFactory = BasicStaffViewControllerFactory(staffLoader: staffLoader,
                                                                         teamLoader: teamLoader,
                                                                         creationservice: staffCreationservice)
        
        let clubHomeCoordinatorFactory = BasicClubHomeCoordinatorFactory(navigationController: navigationController,
                                                                         playersViewControllerFactory: playersViewControllerFactory,
                                                                         teamViewControllerFactory: teamViewControllerFactory,
                                                                         groupsViewControllerFactory: groupViewControllerFactory,
                                                                         staffViewControllerFactory: staffViewControllerFactory)
        
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
