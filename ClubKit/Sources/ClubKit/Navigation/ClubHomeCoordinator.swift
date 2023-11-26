//
//  File.swift
//  
//
//  Created by Findlay-Personal on 14/05/2023.
//

import UIKit

//class ClubHomeCoordinator: ClubHomeFlow {
//    
//    var navigationController: UINavigationController
//    var viewControllerFactoy: ViewControllerFactory
//    var coordinatorFactory: CoordinatorFactory
//    var clubModel: RemoteClubModel
//    
//    init(navigationController: UINavigationController, viewControllerFactory: ViewControllerFactory, coordinatorFactory: CoordinatorFactory, clubModel: RemoteClubModel) {
//        self.navigationController = navigationController
//        self.viewControllerFactoy = viewControllerFactory
//        self.coordinatorFactory = coordinatorFactory
//        self.clubModel = clubModel
//    }
//    
//    func start() {
//        let vc = viewControllerFactoy.makeClubHomeViewController(clubModel)
//        vc.hidesBottomBarWhenPushed = true
//        vc.coordinator = self
//        navigationController.pushViewController(vc, animated: true)
//    }
//    
//    func goToTeams() {
////        let vc = viewControllerFactoy.makeTeamsViewController(clubModel, flow: self)
////        navigationController.pushViewController(vc, animated: true)
//    }
//    
//    func goToTeam(_ model: RemoteTeamModel) {
////        let child = coordinatorFactory.makeTeamCoordinator(for: model)
////        child.start()
//    }
//    
//    func goToPlayers() {
////        let vc = viewControllerFactoy.makePlayersViewController(clubModel)
////        vc.coordinator = self
////        navigationController.pushViewController(vc, animated: true)
//    }
//    
//    func goToCreatePlayer() {
////        let vc = viewControllerFactoy.makeCreatePlayerViewController(clubModel)
////        navigationController.pushViewController(vc, animated: true)
//    }
//    
//    func goToGroups() {
//        
//    }
//}

protocol ClubHomeFlow: Coordinator {
    func goToTeams()
    func goToTeam(_ model: RemoteTeamModel)
    func goToPlayers()
    func goToCreatePlayer()
    func goToGroups()
    func goToStaff()
    func goToQRScanner()
}

class BasicClubHomeFlow: ClubHomeFlow {
    
    var navigationController: UINavigationController
    var viewControllerFactory: ClubHomeViewControllerFactory
    var coordinatorFactory: ClubHomeCoordinatorFactory
    var clubModel: RemoteClubModel
    
    init(navigationController: UINavigationController, viewControllerFactory: ClubHomeViewControllerFactory, clubHomeCoordinatorFactory: ClubHomeCoordinatorFactory, clubModel: RemoteClubModel) {
        self.navigationController = navigationController
        self.viewControllerFactory = viewControllerFactory
        self.coordinatorFactory = clubHomeCoordinatorFactory
        self.clubModel = clubModel
    }
    
    func start() {
        let vc = viewControllerFactory.makeClubHomeViewController(with: clubModel)
        vc.coordinator = self
        navigationController.pushViewController(vc, animated: true)
    }
    
    func goToTeams() {
        let flow = coordinatorFactory.makeTeamsCoordinator(with: clubModel)
        flow.start()
    }
    
    func goToTeam(_ model: RemoteTeamModel) {
        
    }
    
    func goToPlayers() {
        let flow = coordinatorFactory.makePlayersCoordinator(with: clubModel)
        flow.start()
    }
    
    func goToCreatePlayer() {
        
    }
    
    func goToGroups() {
        let flow = coordinatorFactory.makeGroupsCoordinator(with: clubModel)
        flow.start()
    }
    
    func goToStaff() {
        let flow = coordinatorFactory.makeStaffCoordinator(with: clubModel)
        flow.start()
    }
    func goToQRScanner() {
        let vc = viewControllerFactory.makeQRScannerViewController(with: clubModel)
        navigationController.pushViewController(vc, animated: true)
    }
}
