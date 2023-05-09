//
//  File.swift
//  
//
//  Created by Findlay-Personal on 08/05/2023.
//

import Foundation

protocol CoordinatorFactory {
    func makeHomeWorkoutCoordinator() -> WorkoutsHomeFlow
    func makeDiplayWorkoutCoordinator(workout: RemoteWorkoutModel) -> DisplayFlow
    func makeWorkoutCreationCoordinator() -> CreationFlow
}

extension Factory: CoordinatorFactory {
    func makeHomeWorkoutCoordinator() -> WorkoutsHomeFlow {
        let coordinator = WorkoutsHomeCoordinator(factory: self)
        return coordinator
    }
    func makeDiplayWorkoutCoordinator(workout: RemoteWorkoutModel) -> DisplayFlow {
        let coordinator = DisplayCoordinator(factory: self, workout: workout)
        return coordinator
    }
    func makeWorkoutCreationCoordinator() -> CreationFlow {
        return CreationCoordinator(factory: self)
    }
}

class LoggingCoordinator: CoordinatorFactory {
    
    var decoratee: CoordinatorFactory
    
    init(decoratee: CoordinatorFactory) {
        self.decoratee = decoratee
    }
    
    func makeHomeWorkoutCoordinator() -> WorkoutsHomeFlow {
        let coordinator = WorkoutsHomeCoordinator(factory: self)
        return coordinator
    }
    func makeDiplayWorkoutCoordinator(workout: RemoteWorkoutModel) -> DisplayFlow {
        let coordinator = DisplayCoordinator(factory: self, workout: workout)
        return coordinator
    }
    func makeWorkoutCreationCoordinator() -> CreationFlow {
        return CreationCoordinator(factory: self)
    }
}
