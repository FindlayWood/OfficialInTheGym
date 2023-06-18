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
    
    var loginKitInterface: Boundary

    init(navigationController: UINavigationController, completion: @escaping () -> Void) {
        loginKitInterface = .init(navigationController: navigationController, apiService: LoginKitNetworkService(), colour: .darkColour, title: "INTHEGYM", image: UIImage(named: "inthegym_icon3")!, completion: completion)
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

