//
//  AccountCreationComposition.swift
//  InTheGym
//
//  Created by Findlay-Personal on 12/04/2023.
//  Copyright © 2023 FindlayWood. All rights reserved.
//

import AccountCreationKit
import UIKit

class AccountCreationComposition {
    
    var accountCreationKitInterface: Boundary

    init(navigationController: UINavigationController, email: String, uid: String) {
        accountCreationKitInterface = .init(navigationController: navigationController,
                                            apiService: AccountCreationKitNetworkService(),
                                            colour: .darkColour,
                                            image: UIImage(named: "inthegym_icon3")!,
                                            email: email,
                                            uid: uid)
    }
    
}

class AccountCreationKitNetworkService: NetworkService {
    
    var apiService: FirebaseDatabaseManagerService
    var authService: AuthManagerService
    var firestoreService: FirestoreService
    var storageService = FirebaseStorageManager.shared
    
    init(apiService: FirebaseDatabaseManagerService = FirebaseDatabaseManager.shared,
         authService: AuthManagerService = FirebaseAuthManager.shared,
         firestoreService: FirestoreService = FirestoreManager.shared) {
        self.apiService = apiService
        self.authService = authService
        self.firestoreService = firestoreService
    }
    
    func signout() async throws {
        try authService.signout()
    }
    
    func upload(data: Codable, at path: String) async throws {
        try await firestoreService.upload(data: data, at: path)
    }
    
    func uploadRealtime(data: Codable, at path: String) async throws {
        try await apiService.upload(data: data, at: path)
    }
    
    func dataUpload(data: Data, at path: String) async throws {
        try await storageService.dataUploadAsync(data: data, at: path)
    }
    
    func checkExistence(at path: String) async throws -> Bool {
        try await apiService.checkExistence(at: path)
    }
}
