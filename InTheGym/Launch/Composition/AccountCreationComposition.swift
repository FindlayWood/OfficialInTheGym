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
    
    var navigationController: UINavigationController
    var email: String
    var uid: String
    var completedCallback: () -> Void
    var signOutCallback: () -> Void
    
    init(navigationController: UINavigationController, email: String, uid: String, completion: @escaping () -> Void, signOut: @escaping () -> Void) {
        self.navigationController = navigationController
        self.email = email
        self.uid = uid
        self.completedCallback = completion
        self.signOutCallback = signOut
    }
    
    func makeInterface() -> AccountCreationKitInterface {
        
        let userModel = AccountCreationUserModel(
            email: email,
            uid: uid
        )
        
        let mainInterface = MainAccountCreationKitInterface(
            navigationController: navigationController,
            networkService: AccountCreationKitNetworkService(),
            userModel: userModel,
            colour: .darkColour,
            completedCallback: completedCallback,
            signOutCallback: signOutCallback
        )
        
        
        return mainInterface
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
    
    func upload(dataPoints: [String: Codable]) async throws {
        try await firestoreService.upload(dataPoints: dataPoints)
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


protocol AccountCreationComposer {
    func makeAccountCreationInterface(with email: String, uid: String) -> AccountCreationKitInterface
}

struct AccountCreationComposerAdapter: AccountCreationComposer {
    var navigationController: UINavigationController
    var completion: () -> Void
    var signedOut: () -> Void
    
    func makeAccountCreationInterface(with email: String, uid: String) -> AccountCreationKitInterface {
        let comp = AccountCreationComposition(
            navigationController: navigationController,
            email: email,
            uid: uid,
            completion: completion,
            signOut: signedOut)
        let interface = comp.makeInterface()
        return interface
    }
}
