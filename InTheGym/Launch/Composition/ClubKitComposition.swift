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
}


class ClubKitNetWorkService: NetworkService {
    
    var firebaseService: FirebaseDatabaseManagerService
    var firestoreService: FirestoreService
    
    init(firestoreService: FirestoreService = FirestoreManager.shared, firebaseService: FirebaseDatabaseManagerService = FirebaseDatabaseManager.shared) {
        self.firestoreService = firestoreService
        self.firebaseService = firebaseService
    }
    
    func write(data: Codable, at path: String) async throws {
        try await firestoreService.upload(data: data, at: path)
    }
    
    func read<T: Codable>(at path: String) async throws -> T {
        return try await firestoreService.read(at: path)
    }
    
    func readAll<T: Codable>(at path: String) async throws -> [T] {
        return try await firestoreService.readAll(at: path)
    }
}
