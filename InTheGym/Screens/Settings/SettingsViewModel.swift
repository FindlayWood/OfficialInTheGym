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
        apiService.logout { [weak self] success in
            if success {
                LikesAPIService.shared.LikedPostsCache.removeAll()
                ViewController.admin = nil
                ViewController.username = nil
                LikeCache.shared.removeAll()
                ClipCache.shared.removeAll()
                let fcmTokenModel = FCMTokenModel(fcmToken: nil, tokenUpdatedDate: .now)
                Task {
                    do {
                        try await FirestoreManager.shared.upload(fcmTokenModel)
                        UserDefaults.standard.removeObject(forKey: UserDefaults.Keys.currentUser.rawValue)
                    } catch {
                        print(String(describing: error))
                    }
                }
                self?.loggedOut()
            } else {
                self?.errorLoggingOut.send(true)
            }
        }
    }
    func resetPassword() {
        apiService.sendResetPassword(to: UserDefaults.currentUser.email) { [weak self] success in
            self?.successfullySentResetPassword.send(success)
        }
    }
    // MARK: - Success
    func loggedOut() {
        let appDelegate = UIApplication.shared.delegate as! AppDelegate
        appDelegate.nilUser()
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
