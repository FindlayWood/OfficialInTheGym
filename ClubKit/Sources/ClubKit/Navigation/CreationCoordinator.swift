//
//  File.swift
//  
//
//  Created by Findlay-Personal on 14/05/2023.
//

import UIKit

protocol ClubCreationFlow: Coordinator {
    func successfullyCreatedNewClub()
}

class BasicClubCreationFlow: ClubCreationFlow {
    
    var navigationController: UINavigationController
    var viewControllerFactory: ClubCreationViewControllerFactory
    
    init(navigationController: UINavigationController, viewControllerFactory: ClubCreationViewControllerFactory) {
        self.navigationController = navigationController
        self.viewControllerFactory = viewControllerFactory
    }
    
    func start() {
        let vc = viewControllerFactory.makeClubCreationViewController()
        navigationController.present(vc, animated: true)
    }
    
    func successfullyCreatedNewClub() {
        
    }
}
