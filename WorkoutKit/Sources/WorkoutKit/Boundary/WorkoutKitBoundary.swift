//
//  File.swift
//  
//
//  Created by Findlay-Personal on 29/04/2023.
//

import UIKit

public class WorkoutKitBoundary {
    
    var coordinator: WorkoutsHomeCoordinator?
    
    public init(navigationController: UINavigationController, apiService: NetworkService, userService: CurrentUserServiceWorkoutKit) {
        coordinator = .init(navigationController: navigationController, apiService: apiService, userService: userService)
    }
    
    public func compose() {
        coordinator?.start()
    }
}
