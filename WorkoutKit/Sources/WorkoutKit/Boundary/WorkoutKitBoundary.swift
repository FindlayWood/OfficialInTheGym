//
//  File.swift
//  
//
//  Created by Findlay-Personal on 29/04/2023.
//

import UIKit

public class WorkoutKitBoundary {
    
    var coordinator: WorkoutsHomeCoordinator?
    
    public init(navigationController: UINavigationController) {
        coordinator = .init(navigationController: navigationController)
    }
    
    public func compose() {
        coordinator?.start()
    }
}
