//
//  File.swift
//  
//
//  Created by Findlay Wood on 20/11/2023.
//

import UIKit

protocol GroupFlow: Coordinator {
 
}

class BasicGroupFlow: GroupFlow {

    var navigationController: UINavigationController
    var viewControllerFactory: GroupsViewControllerFactory
    var clubModel: RemoteClubModel
    
    init(navigationController: UINavigationController, viewControllerFactory: GroupsViewControllerFactory, clubModel: RemoteClubModel) {
        self.navigationController = navigationController
        self.viewControllerFactory = viewControllerFactory
        self.clubModel = clubModel
    }
    
    func start() {
        let vc = viewControllerFactory.makeGroupsViewController(for: clubModel)
        vc.coordinator = self
        navigationController.pushViewController(vc, animated: true)
    }
}
