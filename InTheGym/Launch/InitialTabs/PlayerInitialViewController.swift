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
        // MARK: - Workouts
        let workoutsNavigationController = UINavigationController()
        workoutsNavigationController.tabBarItem = UITabBarItem(title: "WORKOUTS", image: UIImage(named: "dumbell"), tag: 2)
        let workoutsCoordinator = WorkoutsCoordinator(navigationController: workoutsNavigationController)
        workoutsCoordinator.start()
        // MARK: - Workout Kit
        let workoutKitNavigationController = UINavigationController()
        workoutKitNavigationController.tabBarItem = UITabBarItem(title: "WORKOUTS", image: UIImage(named: "dumbell"), tag: 2)
        let workoutKitComposition = WorkoutKitComposition(navigaitonController: workoutKitNavigationController)
//        workoutKitComposition.compose()
        // MARK: - Profile
        let myProfileNavigationController = UINavigationController()
        myProfileNavigationController.tabBarItem = UITabBarItem(title: "MYPROFILE", image: UIImage(systemName: "person.fill"), tag: 3)
        let myProfileCoordinator = MyProfileCoordinator(navigationController: myProfileNavigationController)
        myProfileCoordinator.start()
        
        viewControllers = [timelineNavigationController, discoverNavigationController, workoutsNavigationController, myProfileNavigationController]
    }
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        navigationController?.setNavigationBarHidden(true, animated: false)
        tabBar.backgroundColor = .systemBackground
        tabBar.tintColor = .darkColour
        tabBar.barTintColor = .systemBackground
    }
}
