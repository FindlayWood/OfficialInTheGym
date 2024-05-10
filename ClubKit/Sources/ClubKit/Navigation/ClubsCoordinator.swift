//
//  File.swift
//  
//
//  Created by Findlay-Personal on 10/05/2023.
//

import UIKit

class ClubsCoordinator: ClubsFlow {
    
    var navigationController: UINavigationController
    var viewControllerFactoy: BaseViewControllerFactory
    var coordinatorFactory: ClubsCoordinatorFactory
    
    init(navigationController: UINavigationController, viewControllerFactory: BaseViewControllerFactory, coordinatorFactory: ClubsCoordinatorFactory) {
        self.navigationController = navigationController
        self.viewControllerFactoy = viewControllerFactory
        self.coordinatorFactory = coordinatorFactory
    }
    
    func start() {
        let vc = viewControllerFactoy.makeBaseViewController(with: self)
        navigationController.setViewControllers([vc], animated: true)
    }
    func goToCreationAction() {
        let flow = coordinatorFactory.makeCeationCoordinator()
        flow.start()
    }
    func goToClubAction(_ clubModel: RemoteClubModel) {
        let flow = coordinatorFactory.makeClubHomeCoordinator(with: clubModel)
        flow.start()
    }
    func goToQRCode() {
        let vc = viewControllerFactoy.makeQRViewController()
        navigationController.present(vc, animated: true)
    }
}

protocol ClubsFlow: Coordinator {
    func goToCreationAction()
    func goToClubAction(_ clubModel: RemoteClubModel)
    func goToQRCode()
}
