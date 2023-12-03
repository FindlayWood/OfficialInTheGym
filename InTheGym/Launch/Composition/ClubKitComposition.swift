//
//  ClubKitComposition.swift
//  InTheGym
//
//  Created by Findlay-Personal on 14/05/2023.
//  Copyright © 2023 FindlayWood. All rights reserved.
//

import ClubKit
import UIKit

class ClubKitComposition {
    
    var navigationController: UINavigationController
    
    init(navigaitonController: UINavigationController) {
        self.navigationController = navigaitonController
        compose()
    }
    
    func compose() {
        let userService = ClubKitCurrentUserModel()
        let networkService = ClubKitNetWorkService()
        let clubKitBoundary = ClubKitBoundary(navigationController: navigationController, networkService: networkService, userService: userService)
        clubKitBoundary.compose()
    }
}


class ClubKitCurrentUserModel: CurrentUserService {
    var currentUserUID: String {
        return UserDefaults.currentUser.uid
    }
    var displayName: String {
        return UserDefaults.currentUser.displayName
    }
    var username: String {
        return UserDefaults.currentUser.username
    }
}


class ClubKitNetWorkService: NetworkService {
    
    var firebaseService: FirebaseDatabaseManagerService
    var firestoreService: FirestoreService
    var functionsService: FunctionsManager
    
    init(firestoreService: FirestoreService = FirestoreManager.shared,
         firebaseService: FirebaseDatabaseManagerService = FirebaseDatabaseManager.shared,
         functionsService: FunctionsManager = FirebaseFunctionsManager()) {
        self.firestoreService = firestoreService
        self.firebaseService = firebaseService
        self.functionsService = functionsService
    }
    
    func write(dataPoints: [String: Codable]) async throws {
        try await firestoreService.upload(dataPoints: dataPoints)
    }
    
    func read<T: Codable>(at path: String) async throws -> T {
        return try await firestoreService.read(at: path)
    }
    
    func readAll<T: Codable>(at path: String) async throws -> [T] {
        return try await firestoreService.readAll(at: path)
    }
    
    func callFunction(named: String, with data: Any) async throws {
        try await functionsService.callable(named: named, data: data)
    }
}
