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
    
    var baseFlow: BaseFlow?
    var apiService: AuthManagerService
    var signOutAction: (() -> Void)?
    
    init(apiService: AuthManagerService = FirebaseAuthManager.shared) {
        self.apiService = apiService
        user = Auth.auth().currentUser
        initTimer()
    }
    
    var timer = Timer()

    func initTimer() {
        self.timer = Timer.scheduledTimer(withTimeInterval: 2, repeats: true, block: { [weak self] _ in
            self?.verifiedEmailAction()
        })
    }

    func verifiedEmailAction() {
        guard let user else {return}
        Task {
            do {
                try await user.reload()
                if user.isEmailVerified {
                    DispatchQueue.main.async {
                        self.goToAccountCreation()
                    }
                }
            } catch {
                print(String(describing: error))
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
            signOutAction?()
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
