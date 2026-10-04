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
        // MARK: - Workouts
        let workoutsNavigationController = UINavigationController()
        workoutsNavigationController.tabBarItem = UITabBarItem(title: "WORKOUTS", image: UIImage(named: "dumbell"), tag: 2)
        let workoutsCoordinator = WorkoutsCoordinator(navigationController: workoutsNavigationController, subscriptionManager: subscriptionManager)
        workoutsCoordinator.start()
        
        // MARK: - MyDay
        let myDayKit = MyDayKitComposition()
        let myDayNavigationController = UINavigationController()
        myDayKit.composeCombination(myDayNavigationController)
        myDayNavigationController.tabBarItem = UITabBarItem(title: "MYDAY", image: UIImage(systemName: "list.dash"), tag: 4)

        // MARK: - Discover
        // Composed after MyDay: "Save to Library" writes through MyDay's own
        // template saver and library manager, so a saved workout shows in the
        // MyDay library at once — see `MyDayWorkoutLibrary`.
        let discoverKit = DiscoverKitComposition()
        let discoverNavigationController = UINavigationController()
        discoverKit.composeCombination(discoverNavigationController, workoutLibrary: myDayKit.workoutLibrary, purchaseManager: subscriptionManager)
        discoverNavigationController.tabBarItem = UITabBarItem(title: "DISCOVER", image: UIImage(systemName: "magnifyingglass"), tag: 1)
        
        // MARK: - Stats Kit
        let statsKit = StatsKitComposition()
        let statsKitNavigationController = UINavigationController()
        statsKit.composeCombination(statsKitNavigationController)
        statsKitNavigationController.tabBarItem = UITabBarItem(title: "STATS", image: UIImage(systemName: "chart.bar.fill"), tag: 5)
        
        // MARK: - Profile
        // ProfileKit. The coach tab bar still uses the legacy MyProfileCoordinator.
        let profileKit = ProfileKitComposition()
        let myProfileNavigationController = UINavigationController()
        profileKit.composeCombination(myProfileNavigationController, purchaseManager: subscriptionManager)
        myProfileNavigationController.tabBarItem = UITabBarItem(title: "MYPROFILE", image: UIImage(systemName: "person.fill"), tag: 6)
        
        viewControllers = [timelineNavigationController, discoverNavigationController, myDayNavigationController, statsKitNavigationController, myProfileNavigationController]
    }
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        navigationController?.setNavigationBarHidden(true, animated: false)
        tabBar.tintColor = .darkColour
        tabBar.barTintColor = .systemBackground
    }
}
