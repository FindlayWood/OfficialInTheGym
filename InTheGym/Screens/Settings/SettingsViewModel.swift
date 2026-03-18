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
    var errorLoggingOut = PassthroughSubject<Bool, Never>()
    
    // MARK: - Properties
    var apiService: AuthManagerService = FirebaseAuthManager.shared
    var firestoreService: FirestoreService
    var userSignedOut: (() -> Void)?
    
    let navigationTitle: String = "Settings"
    
    // MARK: - Initializer
    init(apiService: AuthManagerService = FirebaseAuthManager.shared, firestoreService: FirestoreService = FirestoreManager.shared) {
        self.apiService = apiService
        self.firestoreService = firestoreService
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
        Task { @MainActor in
            do {
                let fcmTokenModel = FCMTokenModel(fcmToken: nil, tokenUpdatedDate: .now)
                try await firestoreService.upload(dataPoints: ["FCMTokens/\(UserDefaults.currentUser.uid)": fcmTokenModel])
                UserDefaults.standard.removeObject(forKey: UserDefaults.Keys.currentUser.rawValue)
                try apiService.signout()
                NotificationCenter.default.post(name: Notification.signOut, object: nil)
                LikeCache.shared.removeAll()
                ClipCache.shared.removeAll()
            } catch {
                self.errorLoggingOut.send(true)
            }
        }
    }
    func resetPassword() {
        Task {
            do {
                try await apiService.forgotPassword(for: UserDefaults.currentUser.email)
                self.successfullySentResetPassword.send(true)
            } catch {
                self.successfullySentResetPassword.send(false)
            }
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
