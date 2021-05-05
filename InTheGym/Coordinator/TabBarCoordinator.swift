//
//  TabBarCoordinator.swift
//  InTheGym
//
//  Created by Findlay Wood on 05/05/2021.
//  Copyright © 2021 FindlayWood. All rights reserved.
//

import Foundation
import UIKit

class TabBarCoordinator: Coordinator {
    
    var childCoordinators = [Coordinator]()
    var navigationController: UINavigationController
    
    init(navigationController: UINavigationController){
        self.navigationController = navigationController
    }
    
    func start() {
        let tabBarController = PlayerInitialViewController.instantiate()
        tabBarController.coordinator = self
        
        if ViewController.admin{
            print("admin is here")
        } else {
            print("no admin here")
        }
        
        let timelineNavigationController = UINavigationController()
        timelineNavigationController.tabBarItem = UITabBarItem(tabBarSystemItem: .favorites, tag: 0)
        let timeLineCoord = TimelineCoordinator(navigationController: timelineNavigationController)
        
        let discoverNavigationController = UINavigationController()
        discoverNavigationController.tabBarItem = UITabBarItem(tabBarSystemItem: .search, tag: 1)
        let discoverCoord = DiscoverCoordinator(navigationController: discoverNavigationController)
        
        let workoutsNavigationController = UINavigationController()
        workoutsNavigationController.tabBarItem = UITabBarItem(tabBarSystemItem: .downloads, tag: 2)
        let workoutsCoord = WorkoutsCoordinator(navigationController: workoutsNavigationController)
        
        let playersNavigationController = UINavigationController()
        playersNavigationController.tabBarItem = UITabBarItem(tabBarSystemItem: .history, tag: 2)
        let playerCoord = PlayersCoordinator(navigationController: playersNavigationController)
        
        let myProfileNavigationController = UINavigationController()
        myProfileNavigationController.tabBarItem = UITabBarItem(tabBarSystemItem: .more, tag: 3)
        let myProfileCoord = MyProfileCoordinator(navigationController: myProfileNavigationController)
        
        if ViewController.admin {
            tabBarController.viewControllers = [timelineNavigationController,
                                                discoverNavigationController,
                                                playersNavigationController,
                                                myProfileNavigationController]
                                                
        } else {
            tabBarController.viewControllers = [timelineNavigationController,
                                                discoverNavigationController,
                                                workoutsNavigationController,
                                                myProfileNavigationController]
        }
        
        //tabBarController.viewControllers = [timelineNavigationController, discoverNavigationController]
        tabBarController.modalPresentationStyle = .fullScreen
        navigationController.present(tabBarController, animated: false, completion: nil)
        
        coordinate(to: timeLineCoord)
        coordinate(to: discoverCoord)
        coordinate(to: myProfileCoord)
        if ViewController.admin{
            coordinate(to: playerCoord)
        } else {
            coordinate(to: workoutsCoord)
        }
    }
    
    func coordinateToMain(){
        let main = MainCoordinator(navigationController: navigationController)
        coordinate(to: main)
    }
    
    
}
