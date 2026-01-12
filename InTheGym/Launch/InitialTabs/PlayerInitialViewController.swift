//
//  PlayerInitialViewController.swift
//  InTheGym
//
//  Created by Findlay Wood on 04/05/2021.
//  Copyright © 2021 FindlayWood. All rights reserved.
//

import UIKit

class PlayerInitialViewController: UITabBarController {

    weak var coordinator: TabBarCoordinator?
    var subscriptionManager: PurchaseManager
    
    init(subscriptionManager: PurchaseManager) {
        self.subscriptionManager = subscriptionManager
        super.init(nibName: nil, bundle: nil)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // MARK: - Timeline
        let timelineNavigationController = UINavigationController()
        timelineNavigationController.tabBarItem = UITabBarItem(title: "NEWSFEED", image: UIImage(systemName: "newspaper.fill"), tag: 0)
        let timeLineCoordinator = TimelineCoordinator(navigationController: timelineNavigationController, subscriptionManager: subscriptionManager)
        timeLineCoordinator.start()
        // MARK: - Discover
        let discoverNavigationController = UINavigationController()
        discoverNavigationController.tabBarItem = UITabBarItem(title: "DISCOVER", image: UIImage(systemName: "magnifyingglass"), tag: 1)
        let discoverCoordinator = DiscoverCoordinator(navigationController: discoverNavigationController, subscriptionManager: subscriptionManager)
        discoverCoordinator.start()
        // MARK: - ClubKit
        let clubKitNavigationController = UINavigationController()
        clubKitNavigationController.tabBarItem = UITabBarItem(title: "CLUBS", image: UIImage(systemName: "person.3.fill"), tag: 2)
        let clubKitComposition = ClubKitComposition(navigaitonController: clubKitNavigationController)
        // MARK: - Workouts
        let workoutsNavigationController = UINavigationController()
        workoutsNavigationController.tabBarItem = UITabBarItem(title: "WORKOUTS", image: UIImage(named: "dumbell"), tag: 2)
        let workoutsCoordinator = WorkoutsCoordinator(navigationController: workoutsNavigationController, subscriptionManager: subscriptionManager)
        workoutsCoordinator.start()
        // MARK: - Workout Kit
        let workoutKitNavigationController = UINavigationController()
        workoutKitNavigationController.tabBarItem = UITabBarItem(title: "WORKOUTS", image: UIImage(named: "dumbell"), tag: 3)
        let workoutKitComposition = WorkoutKitComposition(navigaitonController: workoutKitNavigationController)
//        workoutKitComposition.compose()
        
        // MARK: - MyDay
        let myDayKit = MyDayKitComposition()
        let hostedViewController = myDayKit.compose()
        hostedViewController.tabBarItem = UITabBarItem(title: "MYDAY", image: UIImage(systemName: "list.dash"), tag: 4)
        
        // MARK: - Profile
        let myProfileNavigationController = UINavigationController()
        myProfileNavigationController.tabBarItem = UITabBarItem(title: "MYPROFILE", image: UIImage(systemName: "person.fill"), tag: 5)
        let myProfileCoordinator = MyProfileCoordinator(navigationController: myProfileNavigationController, subscriptionManager: subscriptionManager)
        myProfileCoordinator.start()
        
        viewControllers = [timelineNavigationController, discoverNavigationController, workoutsNavigationController,  hostedViewController, myProfileNavigationController]
    }
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        navigationController?.setNavigationBarHidden(true, animated: false)
        tabBar.backgroundColor = .systemBackground
        tabBar.tintColor = .darkColour
        tabBar.barTintColor = .systemBackground
    }
}
