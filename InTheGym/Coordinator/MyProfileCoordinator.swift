//
//  MyProfileCoordinator.swift
//  InTheGym
//
//  Created by Findlay Wood on 05/05/2021.
//  Copyright © 2021 FindlayWood. All rights reserved.
//

import Foundation
import UIKit

protocol MyProfileFlow: TimelineFlow {
    func showGroups()
    func showNotifications()
    func showSavedWorkouts()
    func showCreatedWorkouts()
    func showScores()
    func editProfile()
    func showMore()
    func logout()
}

class MyProfileCoordinator: Coordinator {
    
    var childCoordinators = [Coordinator]()
    var navigationController: UINavigationController
    
    init(navigationController: UINavigationController){
        self.navigationController = navigationController
        self.navigationController.navigationBar.setBackgroundImage(UIImage(), for: .default)
        self.navigationController.navigationBar.shadowImage = UIImage()
        self.navigationController.navigationBar.tintColor = .white
    }
    
    func start() {
        let vc = MyProfileViewController.instantiate()
        vc.coordinator = self
        navigationController.pushViewController(vc, animated: true)
    }
    
}

//MARK: - Flow Methods
extension MyProfileCoordinator: MyProfileFlow {
    func showDiscussion() {
        
    }
    
    func showUser() {
        
    }
    
    func showWorkouts() {
    
    }
    func showGroups() {
        
    }
    
    func showNotifications() {
        
    }
    
    func showSavedWorkouts() {
        
    }
    
    func showCreatedWorkouts() {
        
    }
    
    func showScores() {
        
    }
    
    func editProfile() {
        
    }
    
    func showMore() {
        
    }
    
    func logout() {
        let main = MainCoordinator(navigationController: navigationController)
        coordinate(to: main)
    }

}
