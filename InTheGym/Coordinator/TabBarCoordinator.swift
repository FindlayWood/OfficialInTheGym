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
    //var tabBarController: PlayerInitialViewController!
    
    init(navigationController: UINavigationController){
        self.navigationController = navigationController
    }
    
    func start() {
        let tabBarController = PlayerInitialViewController.instantiate()
        //tabBarController = PlayerInitialViewController.instantiate()
        tabBarController.coordinator = self
        
        let timelineNavigationController = UINavigationController()
        if #available(iOS 13.0, *) {
            timelineNavigationController.tabBarItem = UITabBarItem(title: "NEWSFEED", image: UIImage(systemName: "newspaper.fill"), tag: 0)
        } else {
            timelineNavigationController.tabBarItem = UITabBarItem(tabBarSystemItem: .favorites, tag: 0)
            timelineNavigationController.tabBarItem.title = "NEWSFEED"
        }
        let timeLineCoord = TimelineCoordinator(navigationController: timelineNavigationController)
        
        
        let discoverNavigationController = UINavigationController()
        if #available(iOS 13.0, *) {
            discoverNavigationController.tabBarItem = UITabBarItem(title: "DISCOVER", image: UIImage(systemName: "magnifyingglass"), tag: 1)
        } else {
            discoverNavigationController.tabBarItem = UITabBarItem(tabBarSystemItem: .contacts, tag: 1)
        }
        let discoverCoord = DiscoverCoordinator(navigationController: discoverNavigationController)
        
        
        let workoutsNavigationController = UINavigationController()
        workoutsNavigationController.tabBarItem = UITabBarItem(title: "WORKOUTS", image: UIImage(named: "dumbell"), tag: 2)
        let workoutsCoord = WorkoutsCoordinator(navigationController: workoutsNavigationController)
        
        
        let playersNavigationController = UINavigationController()
        if #available(iOS 13.0, *) {
            playersNavigationController.tabBarItem = UITabBarItem(title: "PLAYERS", image: UIImage(systemName: "person.2.fill"), tag: 2)
        } else {
            playersNavigationController.tabBarItem = UITabBarItem(tabBarSystemItem: .bookmarks, tag: 2)
            playersNavigationController.tabBarItem.title = "PLAYERS"
        }
        let playerCoord = PlayersCoordinator(navigationController: playersNavigationController)
        
        
        let myProfileNavigationController = UINavigationController()
        if #available(iOS 13.0, *) {
            myProfileNavigationController.tabBarItem = UITabBarItem(title: "MYPROFILE", image: UIImage(systemName: "person.fill"), tag: 3)
        } else {
            myProfileNavigationController.tabBarItem = UITabBarItem(tabBarSystemItem: .featured, tag: 3)
            myProfileNavigationController.tabBarItem.title = "MYPROFILE"
        }
        let myProfileCoord = MyProfileCoordinator(navigationController: myProfileNavigationController)
        
        
        if FirebaseAuthManager.currentlyLoggedInUser.admin {
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
        
        
        tabBarController.modalPresentationStyle = .fullScreen
        navigationController.present(tabBarController, animated: true, completion: nil)
        
        coordinate(to: timeLineCoord)
        coordinate(to: discoverCoord)
        coordinate(to: myProfileCoord)
        if FirebaseAuthManager.currentlyLoggedInUser.admin{
            coordinate(to: playerCoord)
        } else {
            coordinate(to: workoutsCoord)
        }
        //observeForNotifications()
    }
    
    func coordinateToMain(){
        let main = MainCoordinator(navigationController: navigationController)
        coordinate(to: main)
    }
    
//    func observeForNotifications() {
//        NotificationCenter.default.addObserver(self, selector: #selector(setToUnseenNotifications), name: .unseenNotification, object: nil)
//        NotificationCenter.default.addObserver(self, selector: #selector(setToSeenNotifications), name: .seenAllNotifications, object: nil)
//    }
//    
//    @objc func setToUnseenNotifications() {
//        if let tabItems = tabBarController?.tabBar.items {
//            // In this case we want to modify the badge number of the third tab:
//            let tabItem = tabItems[3]
//            tabItem.badgeValue = "1"
//        }
//    }
//    
//    @objc func setToSeenNotifications() {
//        if let tabItems = tabBarController?.tabBar.items {
//            // In this case we want to modify the badge number of the third tab:
//            let tabItem = tabItems[3]
//            tabItem.badgeValue = "1"
//        }
//    }
}
