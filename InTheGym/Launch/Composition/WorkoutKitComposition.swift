//
//  WorkoutKitComposition.swift
//  InTheGym
//
//  Created by Findlay-Personal on 02/05/2023.
//  Copyright © 2023 FindlayWood. All rights reserved.
//

import UIKit
import WorkoutKit

class WorkoutKitComposition {
    
    var navigationController: UINavigationController
    
    init(navigaitonController: UINavigationController) {
        self.navigationController = navigaitonController
        compose()
    }
    
    func compose() {
        let userService = CurrentUserModel()
        let networkService = WorkoutKitNetWorkService()
        let workoutKitBoundary = WorkoutKitBoundary(navigationController: navigationController, networkService: networkService, userService: userService)
        workoutKitBoundary.compose()
    }
}


class CurrentUserModel: CurrentUserServiceWorkoutKit {
    var currentUserUID: String {
        return UserDefaults.currentUser.uid
    }
}


class WorkoutKitNetWorkService: NetworkService {
    
    var firebaseService: FirebaseDatabaseManagerService
    var firestoreService: FirestoreService
    
    init(firestoreService: FirestoreService = FirestoreManager.shared, firebaseService: FirebaseDatabaseManagerService = FirebaseDatabaseManager.shared) {
        self.firestoreService = firestoreService
        self.firebaseService = firebaseService
    }
    
    func write(data: Codable, at path: String) async throws {
        try await firebaseService.upload(data: data, at: path)
    }
    
    func read<T: Codable>(at path: String) async throws -> T {
        return try await firebaseService.read(at: path)
    }
    
    func readAll<T: Codable>(at path: String) async throws -> [T] {
        return try await firebaseService.readAll(at: path)
    }
}
