//
//  File.swift
//  
//
//  Created by Findlay-Personal on 29/04/2023.
//

import UIKit

public class WorkoutKitBoundary {
    
    private lazy var factory = Factory(
        workoutManager: workoutManager,
        networkService: networkService,
        userService: userService,
        navigationController: navigationController)
    private lazy var workoutLoader = RemoteWorkoutLoader(networkService: networkService, userService: userService)
    private lazy var exerciseLoader = RemoteExerciseLoader(networkService: networkService)
    private lazy var workoutManager = RemoteWorkoutManager(workoutLoader: workoutLoader, exerciseLoader: exerciseLoader)
    var networkService: NetworkService
    var userService: CurrentUserServiceWorkoutKit
    var navigationController: UINavigationController
    
    public init(navigationController: UINavigationController, networkService: NetworkService, userService: CurrentUserServiceWorkoutKit) {
        self.navigationController = navigationController
        self.networkService = networkService
        self.userService = userService
    }
    
    public func compose() {
        let coordinator = factory.makeHomeWorkoutCoordinator()
        coordinator.start()
    }
}
