//
//  VerifyAccountViewModel.swift
//  InTheGym
//
//  Created by Findlay-Personal on 07/04/2023.
//  Copyright © 2023 FindlayWood. All rights reserved.
//

import Foundation
import Firebase

class VerifyAccountViewModel: ObservableObject {
    
    @Published var user: User?
    
    var apiService: AuthManagerService
    
    init(apiService: AuthManagerService = FirebaseAuthManager.shared) {
        self.apiService = apiService
        user = Auth.auth().currentUser
        observeVerification()
    }
    func observeVerification() {
        Auth.auth().addIDTokenDidChangeListener { [weak self] auth, user in
            if let user = user {
                if user.isEmailVerified {
                    self?.goToAccountCreation()
                } 
            }
        }
    }
    func resendVerificationEmailAction() {
        Task {
            do {
                try await apiService.sendEmailVerification()
            } catch {
                print(String(describing: error))
            }
        }
    }
    
    func logoutAction() {
        do {
            try apiService.signout()
        } catch {
            print(String(describing: error))
        }
    }
    func goToAccountCreation() {
        
    }
}
