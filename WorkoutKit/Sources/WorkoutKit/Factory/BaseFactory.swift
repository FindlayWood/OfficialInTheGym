//
//  File.swift
//  
//
//  Created by Findlay-Personal on 04/05/2023.
//

import Foundation
import UIKit

protocol BaseFactory {
    var networkService: NetworkService { get }
    var userService: CurrentUserServiceWorkoutKit { get }
    var navigationController: UINavigationController { get }
}

class Factory: BaseFactory {
    var workoutManager: WorkoutManager
    var networkService: NetworkService
    var userService: CurrentUserServiceWorkoutKit
    var navigationController: UINavigationController
    
    init(workoutManager: WorkoutManager, networkService: NetworkService, userService: CurrentUserServiceWorkoutKit, navigationController: UINavigationController) {
        self.workoutManager = workoutManager
        self.networkService = networkService
        self.userService = userService
        self.navigationController = navigationController
    }
}
