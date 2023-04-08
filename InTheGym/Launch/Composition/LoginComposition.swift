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

    init(navigationController: UINavigationController) {
        loginKitInterface = .init(navigationController: navigationController, apiService: LoginKitNetworkService(), colour: .darkColour, title: "INTHEGYM", image: UIImage(named: "inthegym_icon3")!)
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

import Firebase

class UserObserver {
    
    static let shared = UserObserver()
    
    private init() {}
    
    var handle: DatabaseHandle?
    
    func observeUser() {
        Auth.auth().addStateDidChangeListener { auth, user in
            if let user = user {
                if user.isEmailVerified {
                    let userSearchModel = UserSearchModel(uid: user.uid)
                    self.loadUserModel(from: userSearchModel)
                } else {
                    self.verifyAccount()
                }
            } else if user == nil {
                self.logout()
            }
        }
    }
    func observeAccountCreation(for userUID: String) {
        let ref = Database.database().reference().child("users").child(userUID)
        handle = ref.observe(.value) { [weak self] snapshot in
            do {
                let data = try snapshot.data(as: Users.self)
                self?.login(data)
                ref.removeObserver(withHandle: (self?.handle)!)
            } catch {
                print(String(describing: error))
            }
        }
    }
    // MARK: - Publishers
    @Published var checkingError: checkingForUserError?
    @Published var error: Error?
    // MARK: - Properties
    var apiService: FirebaseDatabaseManagerService = FirebaseDatabaseManager.shared
    var authService: AuthManagerService = FirebaseAuthManager.shared
    var userService: CurrentUserService = CurrentUserManager.shared
    // MARK: - Initializer
    init(apiService: FirebaseDatabaseManagerService = FirebaseDatabaseManager.shared, authService: AuthManagerService = FirebaseAuthManager.shared, userService: CurrentUserService = CurrentUserManager.shared) {
        self.apiService = apiService
        self.authService = authService
        self.userService = userService
    }
    deinit {
        print("deinit launch page view model")
    }
    // MARK: - Functions
    
    /// checking UserDefaults for current user
    /// if exists - log in user and background check firebase and replace user model - firebase could contain updates
    /// if not exists - check firebase for user - if still not exist - show initial screen
    func checkForUserDefault() {
//        userService.launch()
//        if userService.currentUser == Users.nilUser {
//            checkFirebase()
////        }
        if UserDefaults.currentUser == Users.nilUser {
            checkFirebase()
        } else {
            login(UserDefaults.currentUser)
            FirebaseAuthManager.currentlyLoggedInUser = UserDefaults.currentUser
            ViewController.admin = UserDefaults.currentUser.admin /// depreciated
            ViewController.username = UserDefaults.currentUser.username /// depreciated
            backgroundUpdate()
            Task {
                await SubscriptionManager.shared.launch()
            }
            observeUser()
        }
    }
    private func checkFirebase() {
        authService.checkForCurrentUser { [weak self] result in
            switch result {
            case .success(let firebaseUser):
                let userSearchModel = UserSearchModel(uid: firebaseUser.uid)
                self?.loadUserModel(from: userSearchModel)
                self?.observeUser()
            case .failure(let error):
                self?.checkingError = error
                self?.observeUser()
            }
        }
    }
    private func loadUserModel(from model: UserSearchModel) {
        Task {
            do {
                let userModel: Users = try await apiService.fetchSingleInstanceAsync(of: model)
                login(userModel)
                UserDefaults.currentUser = userModel
                userService.storeCurrentUser(userModel)
                FirebaseAuthManager.currentlyLoggedInUser = userModel
//                ViewController.username = userModel.username /// depreciated
//                ViewController.admin = userModel.admin /// depreciated
                await SubscriptionManager.shared.launch()
            } catch {
                self.observeAccountCreation(for: model.uid)
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
            Task {
                do {
                    let model: Users = try await self.apiService.fetchSingleInstanceAsync(of: userSeachModel)
                    UserDefaults.currentUser = model
                } catch {
                    print(String(describing: error))
                }
            }
        }
    }
    
    func login(_ userModel: Users) {
        DispatchQueue.main.async {
            let appDelegate = UIApplication.shared.delegate as! AppDelegate
            if userModel.admin {
                appDelegate.loggedInCoach()
            } else {
                appDelegate.loggedInPlayer()
            }
        }
    }
    
    func verifyAccount() {
        DispatchQueue.main.async {
            let appDelegate = UIApplication.shared.delegate as! AppDelegate
            appDelegate.verifyScreen()
        }
    }
    
    func logout() {
        DispatchQueue.main.async {
            let appDelegate = UIApplication.shared.delegate as! AppDelegate
            appDelegate.nilUser()
        }
    }
}
