//
//  SettingsViewModel.swift
//  InTheGym
//
//  Created by Findlay Wood on 25/04/2022.
//  Copyright © 2022 FindlayWood. All rights reserved.
//

import Foundation
import Combine
import UIKit

class SettingsViewModel {
    
    // MARK: - Publishers
    var successfullyLoggedOut = PassthroughSubject<Bool,Never>()
    var successfullySentResetPassword = PassthroughSubject<Bool,Never>()
    var settingActions = PassthroughSubject<SettingsAction,Never>()
    
    // MARK: - Properties
    var apiService: AuthManagerService = FirebaseAuthManager.shared
    
    let navigationTitle: String = "Settings"
    
    // MARK: - Initializer
    init(apiService: AuthManagerService = FirebaseAuthManager.shared) {
        self.apiService = apiService
    }
    
    // MARK: - Actions
    func about() {
        settingActions.send(.about)
    }
    func icons() {
        settingActions.send(.icons)
    }
    func instagram() {
        settingActions.send(.instagram)
    }
    func website() {
        settingActions.send(.website)
    }
    func resetPasswordTapped() {
        settingActions.send(.resetPassword)

    }
    func logoutTapped() {
        settingActions.send(.logout)

    }
    // MARK: - Functions
    func logout() {
        apiService.sendResetPassword(to: UserDefaults.currentUser.email) { [weak self] success in
            self?.successfullySentResetPassword.send(success)
        }
    }
    func resetPassword() {
        apiService.logout { [weak self] success in
            self?.successfullyLoggedOut.send(success)
        }
    }
}

enum SettingsAction {
    case about
    case icons
    case instagram
    case website
    case resetPassword
    case logout
}
