//
//  File.swift
//  
//
//  Created by Findlay-Personal on 10/05/2023.
//

import UIKit

protocol CoordinatorFactory {
    var navigationController: UINavigationController { get }
    var viewControllerFactory: ViewControllerFactory { get }
    func makeClubsCoordinator() -> ClubsFlow
}

class RegularCoordinatorFactory: CoordinatorFactory {
    var navigationController: UINavigationController
    var viewControllerFactory: ViewControllerFactory
    
    init(navigationController: UINavigationController, viewControllerFactory: ViewControllerFactory) {
        self.navigationController = navigationController
        self.viewControllerFactory = viewControllerFactory
    }
    
    func makeClubsCoordinator() -> ClubsFlow {
        let child = ClubsCoordinator(navigationController: navigationController, viewControllerFactory: viewControllerFactory)
        return child
    }
}
