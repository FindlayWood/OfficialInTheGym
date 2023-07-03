//
//  LoginComposition.swift
//  InTheGym
//
//  Created by Findlay-Personal on 05/04/2023.
//  Copyright © 2023 FindlayWood. All rights reserved.
//

import LoginKit
import UIKit

class LoginComposition {
    
    var navigationController: UINavigationController
    var completion: () -> Void
    
    init(navigationController: UINavigationController, completion: @escaping () -> Void) {
        self.navigationController = navigationController
        self.completion = completion
    }
    
    func makeInterface() -> LoginKitInterface {
        
        let mainInterface = MainLoginKitInterface(
            navigationController: navigationController,
            networkService: LoginKitNetworkService(),
            colour: .darkColour,
            title: "INTHEGYM",
            image: UIImage(named: "inthegym_icon3")!,
            completion: completion)
        
        return mainInterface
    }
}

class LoginKitNetworkService: NetworkService {
    
    var apiService: AuthManagerService
    
    init(apiService: AuthManagerService = FirebaseAuthManager.shared) {
        self.apiService = apiService
    }
    
    func login(with email: String, password: String) async throws {
        try await apiService.login(with: email, password: password)
    }
    
    func signup(with email: String, password: String) async throws {
        try await apiService.signup(with: email, password: password)
    }
    
    func forgotPassword(for email: String) async throws {
        try await apiService.forgotPassword(for: email)
    }
}

protocol LoginComposer {
    func makeLoginInterface() -> LoginKitInterface
}

struct LoginComposerAdapter: LoginComposer {
    var navigationController: UINavigationController
    var completion: () -> Void
    
    func makeLoginInterface() -> LoginKitInterface {
        
        let comp = LoginComposition(
            navigationController: navigationController,
            completion: completion)
        
        let interface = comp.makeInterface()
        return interface
    }
}
