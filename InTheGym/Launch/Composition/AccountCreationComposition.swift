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
    
    init(navigationController: UINavigationController, email: String, uid: String, completion: @escaping () -> Void, signOut: @escaping () -> Void) {
        accountCreationKitInterface = .init(navigationController: navigationController,
                                            apiService: AccountCreationKitNetworkService(),
                                            colour: .darkColour,
                                            email: email,
                                            uid: uid,
                                            callback: completion,
                                            signOut: signOut)
    }
    
}

class AccountCreationKitNetworkService: NetworkService {
    
    var authService: AuthManagerService
    var firestoreService: FirestoreService
    var storageService = FirebaseStorageManager.shared
    var functionsService: FunctionsManager
    
    init(authService: AuthManagerService = FirebaseAuthManager.shared,
         firestoreService: FirestoreService = FirestoreManager.shared,
         functionsService: FunctionsManager = FirebaseFunctionsManager()) {
        self.authService = authService
        self.firestoreService = firestoreService
        self.functionsService = functionsService
    }
    
    func signout() async throws {
        try authService.signout()
    }
    
    func upload(data: Codable, at path: String) async throws {
        try await firestoreService.upload(data: data, at: path)
    }
    
    func dataUpload(data: Data, at path: String) async throws {
        try await storageService.dataUploadAsync(data: data, at: path)
    }
    func read<T:Codable>(at path: String) async throws -> T {
        return try await firestoreService.read(at: path)
    }
    func callFunction(named: String, with data: Any) async throws {
        try await functionsService.callable(named: named, data: data)
    }
}
