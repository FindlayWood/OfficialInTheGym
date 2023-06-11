//
//  VerifyAccountViewModel.swift
//  InTheGym
//
//  Created by Findlay-Personal on 07/04/2023.
//  Copyright © 2023 FindlayWood. All rights reserved.
//

import UIKit
import Firebase

class VerifyAccountViewModel: ObservableObject {
    
    @Published var user: User?
    @Published var isLoading: Bool = false
    @Published var error: Error?
    
    var baseFlow: BaseFlow?
    var apiService: AuthManagerService
    
    init(apiService: AuthManagerService = FirebaseAuthManager.shared) {
        self.apiService = apiService
        user = Auth.auth().currentUser
    }
    
    @MainActor
    func verifiedEmailAction() {
        error = nil
        isLoading = true
        guard let user else {return}
        Task {
            do {
                try await user.reload()
                if user.isEmailVerified {
                    goToAccountCreation()
                    isLoading = false
                } else {
                    error = NSError(domain: "not verified", code: -1)
                    isLoading = false
                }
            } catch {
                print(String(describing: error))
                self.error = error
                isLoading = false
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
        guard let email = user?.email,
              let uid = user?.uid
        else {
            return
        }
        baseFlow?.showAccountCreation(email: email, uid: uid)
    }
}
