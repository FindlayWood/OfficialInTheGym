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
    /// Held here because nothing else retains it: the intro screen holds it weakly.
    private var performanceCoordinator: PerformanceHomeCoordinator?
    
    init(subscriptionManager: PurchaseManager) {
        self.subscriptionManager = subscriptionManager
        super.init(nibName: nil, bundle: nil)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // NEWSFEED is gone from the player tab bar, and with it the WORKOUTS
        // stack that was built here on every launch and never shown. Both
        // coordinators remain: the coach tab bar still has NEWSFEED.

        // MARK: - MyDay
        let myDayKit = MyDayKitComposition()
        let myDayNavigationController = UINavigationController()
        myDayKit.composeCombination(myDayNavigationController)
        myDayNavigationController.tabBarItem = UITabBarItem(title: "MYDAY", image: UIImage(systemName: "list.dash"), tag: 0)

        // MARK: - Discover
        // Composed after MyDay: "Save to Library" writes through MyDay's own
        // template saver and library manager, so a saved workout shows in the
        // MyDay library at once — see `MyDayWorkoutLibrary`.
        let discoverKit = DiscoverKitComposition()
        let discoverNavigationController = UINavigationController()
        discoverKit.composeCombination(discoverNavigationController, workoutLibrary: myDayKit.workoutLibrary, purchaseManager: subscriptionManager)
        discoverNavigationController.tabBarItem = UITabBarItem(title: "DISCOVER", image: UIImage(systemName: "magnifyingglass"), tag: 1)

        // MARK: - Performance
        // The legacy Performance Center, moved as it is from a row in ProfileKit's
        // settings to a tab of its own. Pro is checked when a tool is opened,
        // not here. See `PerformanceHomeCoordinator`.
        let performanceNavigationController = UINavigationController()
        performanceNavigationController.tabBarItem = UITabBarItem(title: "PERFORMANCE", image: UIImage(systemName: "gauge.with.dots.needle.67percent"), tag: 2)
        performanceCoordinator = PerformanceHomeCoordinator(navigationController: performanceNavigationController, user: UserDefaults.currentUser, subscriptionManager: subscriptionManager)
        performanceCoordinator?.startAsTab()

        // MARK: - Stats Kit
        let statsKit = StatsKitComposition()
        let statsKitNavigationController = UINavigationController()
        statsKit.composeCombination(statsKitNavigationController)
        statsKitNavigationController.tabBarItem = UITabBarItem(title: "STATS", image: UIImage(systemName: "chart.bar.fill"), tag: 3)
        
        // MARK: - Profile
        // ProfileKit. The coach tab bar still uses the legacy MyProfileCoordinator.
        let profileKit = ProfileKitComposition()
        let myProfileNavigationController = UINavigationController()
        profileKit.composeCombination(myProfileNavigationController, purchaseManager: subscriptionManager)
        myProfileNavigationController.tabBarItem = UITabBarItem(title: "MYPROFILE", image: UIImage(systemName: "person.fill"), tag: 4)
        
        viewControllers = [myDayNavigationController, discoverNavigationController, performanceNavigationController, statsKitNavigationController, myProfileNavigationController]
    }
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        navigationController?.setNavigationBarHidden(true, animated: false)
        tabBar.tintColor = .darkColour
        tabBar.barTintColor = .systemBackground
    }
}
