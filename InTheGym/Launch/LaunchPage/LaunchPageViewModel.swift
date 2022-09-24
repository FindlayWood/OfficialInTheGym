//
//  LaunchPageViewModel.swift
//  InTheGym
//
//  Created by Findlay Wood on 16/06/2022.
//  Copyright © 2022 FindlayWood. All rights reserved.
//

import Foundation

class LaunchPageViewModel {
    // MARK: - Publishers
    @Published var user: Users?
    @Published var checkingError: checkingForUserError?
    @Published var error: Error?
    // MARK: - Properties
    var apiService: FirebaseDatabaseManagerService = FirebaseDatabaseManager.shared
    var authService: AuthManagerService = FirebaseAuthManager.shared
    // MARK: - Initializer
    init(apiService: FirebaseDatabaseManagerService = FirebaseDatabaseManager.shared, authService: AuthManagerService = FirebaseAuthManager.shared) {
        self.apiService = apiService
        self.authService = authService
    }
    deinit {
        print("deinit launch page view model")
    }
    // MARK: - Functions
    
    /// checking UserDefaults for current user
    /// if exists - log in user and background check firebase and replace user model - firebase could contain updates
    /// if not exists - check firebase for user - if still not exist - show initial screen
    func checkForUserDefault() {
        if UserDefaults.currentUser == Users.nilUser {
            checkFirebase()
        } else {
            user = UserDefaults.currentUser
            FirebaseAuthManager.currentlyLoggedInUser = UserDefaults.currentUser
            ViewController.admin = UserDefaults.currentUser.admin /// depreciated
            ViewController.username = UserDefaults.currentUser.username /// depreciated
            backgroundUpdate()
            Task {
                await SubscriptionManager.shared.launch()
            }
        }
    }
    private func checkFirebase() {
        authService.checkForCurrentUser { [weak self] result in
            switch result {
            case .success(let firebaseUser):
                let userSearchModel = UserSearchModel(uid: firebaseUser.uid)
                self?.loadUserModel(from: userSearchModel)
            case .failure(let error):
                self?.checkingError = error
            }
        }
        
//        FirebaseAuthManager.shared.checkForCurrentUser { [weak self] result in
//            switch result {
//            case .success(let user):
//                let uid = user.uid
//                if uid == UserDefaults.currentUser.uid {
//                    print("matching")
//                    FirebaseAuthManager.currentlyLoggedInUser = UserDefaults.currentUser
//                    ViewController.admin = UserDefaults.currentUser.admin
//                    ViewController.username = UserDefaults.currentUser.username
////                    self?.spinner.stopAnimating()
////                    self?.coordinator?.coordinateToTabBar()
//                } else {
//                    print("not matching")
//                    UserIDToUser.transform(userID: uid) { userObject in
////                        self?.spinner.stopAnimating()
//                        UserDefaults.currentUser = userObject
//                        FirebaseAuthManager.currentlyLoggedInUser = userObject
//                        ViewController.admin = userObject.admin
//                        ViewController.username = userObject.username
////                        self?.coordinator?.coordinateToTabBar()
//                    }
//                }
//
//            case .failure(let error):
////                self?.spinner.stopAnimating()
//                switch error{
//                case .noUser:
//                    print("no user")
//                case .reloadError:
//                    break
////                    self?.showError(with: "There was an error logging you in, please try again.")
//                case .notVerified(let notVerifiedUser):
//                    break
////                    self?.showNotVerified(to: notVerifiedUser)
//                }
////                self?.coordinator?.notLoggedIn()
//            }
//        }
    }
    private func loadUserModel(from model: UserSearchModel) {
        apiService.fetchSingleInstance(of: model, returning: Users.self) { [weak self] result in
            switch result {
            case .success(let userModel):
                self?.user = userModel
                UserDefaults.currentUser = userModel
                FirebaseAuthManager.currentlyLoggedInUser = userModel
                ViewController.username = userModel.username /// depreciated
                ViewController.admin = userModel.admin /// depreciated
                Task {
                    await SubscriptionManager.shared.launch()
                }
            case .failure(let error):
                self?.error = error
            }
        }
    }
    // MARK: - Background Update User Check
    /// on background thread reload the user from the database
    /// update userdefaults user
    func backgroundUpdate() {
        DispatchQueue.global(qos: .background).async {
            let userID = UserDefaults.currentUser.uid
            let userSeachModel = UserSearchModel(uid: userID)
            self.apiService.fetchSingleInstance(of: userSeachModel, returning: Users.self) { result in
                switch result {
                case .success(let userModel):
                    UserDefaults.currentUser = userModel
                case .failure(_):
                    break
                }
            }
        }
    }
}
