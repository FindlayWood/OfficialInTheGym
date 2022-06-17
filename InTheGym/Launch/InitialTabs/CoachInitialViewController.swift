//
//  CoachInitialViewController.swift
//  InTheGym
//
//  Created by Findlay Wood on 17/06/2022.
//  Copyright © 2022 FindlayWood. All rights reserved.
//

import UIKit

class CoachInitialViewController: UITabBarController {

    override func viewDidLoad() {
        super.viewDidLoad()
        // MARK: - Timeline
        let timelineNavigationController = UINavigationController()
        timelineNavigationController.tabBarItem = UITabBarItem(title: "NEWSFEED", image: UIImage(systemName: "newspaper.fill"), tag: 0)
        let timeLineCoordinator = TimelineCoordinator(navigationController: timelineNavigationController)
        timeLineCoordinator.start()
        // MARK: - Discover
        let discoverNavigationController = UINavigationController()
        discoverNavigationController.tabBarItem = UITabBarItem(title: "DISCOVER", image: UIImage(systemName: "magnifyingglass"), tag: 1)
        let discoverCoordinator = DiscoverCoordinator(navigationController: discoverNavigationController)
        discoverCoordinator.start()
        // MARK: - Players
        let playersNavigationController = UINavigationController()
        playersNavigationController.tabBarItem = UITabBarItem(title: "PLAYERS", image: UIImage(systemName: "person.2.fill"), tag: 2)
        let playerCoordinator = PlayersCoordinator(navigationController: playersNavigationController)
        playerCoordinator.start()
        // MARK: - Profile
        let myProfileNavigationController = UINavigationController()
        myProfileNavigationController.tabBarItem = UITabBarItem(title: "MYPROFILE", image: UIImage(systemName: "person.fill"), tag: 3)
        let myProfileCoordinator = MyProfileCoordinator(navigationController: myProfileNavigationController)
        myProfileCoordinator.start()
        
        viewControllers = [timelineNavigationController, discoverNavigationController, playersNavigationController, myProfileNavigationController]
    }
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        navigationController?.setNavigationBarHidden(true, animated: false)
        tabBar.backgroundColor = .systemBackground
        tabBar.tintColor = .darkColour
        tabBar.barTintColor = .systemBackground
    }
}
