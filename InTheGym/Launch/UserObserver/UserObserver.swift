//
//  UserObserver.swift
//  InTheGym
//
//  Created by Findlay-Personal on 21/04/2023.
//  Copyright © 2023 FindlayWood. All rights reserved.
//

import UIKit
import Firebase

class UserObserver {
    
    // MARK: - Publishers
    @Published var checkingError: checkingForUserError?
    @Published var error: Error?
    // MARK: - Properties
    var apiService: FirebaseDatabaseManagerService = FirebaseDatabaseManager.shared
    var firestoreService: FirestoreService = FirestoreManager.shared
    var authService: AuthManagerService = FirebaseAuthManager.shared
    var userService: MainCurrentUserService = CurrentUserManager.shared
    
    static let shared = UserObserver()
    
    private init() {}
    
    var listenerRegistration: ListenerRegistration?
    
    // MARK: - Functions
    /// checking UserDefaults for current user
    /// if exists - log in user and background check firebase and replace user model - firebase could contain updates
    /// if not exists - check firebase for user - if still not exist - show initial screen
    func checkForUserDefault() {
        if UserDefaults.currentUser == Users.nilUser {
            checkFirebase()
        } else {
            login(UserDefaults.currentUser)
            FirebaseAuthManager.currentlyLoggedInUser = UserDefaults.currentUser
            backgroundUpdate()
            Task {
                await SubscriptionManager.shared.launch()
            }
            observeUser()
        }
    }
    
    func observeUser() {
        Auth.auth().addStateDidChangeListener { auth, user in
            if let user = user {
                if user.isEmailVerified {
                    let userSearchModel = UserSearchModel(uid: user.uid)
                    self.loadUserModel(from: userSearchModel, with: user.email)
                } else {
                    self.verifyAccount()
                }
            } else if user == nil {
                self.logout()
            }
        }
    }
    func observeAccountCreation(for userUID: String) {
        let firestoreRef = Firestore.firestore().collection("Users").document(userUID)
        listenerRegistration = firestoreRef.addSnapshotListener { [weak self] snapshot, error in
            if let error {
                print(String(describing: error))
            } else if let snapshot {
                do {
                    let data = try snapshot.data(as: Users.self)
                    self?.setCurrentUser(data)
                    self?.accountCreated()
                } catch {
                    print(String(describing: error))
                }
            }
        }
    }

    private func checkFirebase() {
        Task {
            do {
                let firebaseUser = try await authService.checkForCurrentUser()
                let userSearchModel = UserSearchModel(uid: firebaseUser.uid)
                self.loadUserModel(from: userSearchModel, with: firebaseUser.email)
                self.observeUser()
            } catch {
                self.checkingError = .noUser
                self.observeUser()
            }
        }
    }
    private func loadUserModel(from model: UserSearchModel, with email: String?) {
        Task {
            do {
                let userModel: Users = try await firestoreService.read(at: "Users/\(model.uid)")
                login(userModel)
                UserDefaults.currentUser = userModel
                userService.storeCurrentUser(userModel)
                FirebaseAuthManager.currentlyLoggedInUser = userModel
                await SubscriptionManager.shared.launch()
            } catch {
                guard let email else { return }
                self.createAccount(email: email, uid: model.uid)
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
    
    func setCurrentUser(_ userModel: Users) {
        UserDefaults.currentUser = userModel
        FirebaseAuthManager.currentlyLoggedInUser = userModel
        Task {
            await SubscriptionManager.shared.launch()
        }
    }
    
    func toTheApp() {
        listenerRegistration?.remove()
        login(UserDefaults.currentUser)
    }
    
    func login(_ userModel: Users) {
        DispatchQueue.main.async {
            let appDelegate = UIApplication.shared.delegate as! AppDelegate
            if userModel.accountType == .coach {
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
    
    func createAccount(email: String, uid: String) {
        observeAccountCreation(for: uid)
        DispatchQueue.main.async {
            let appDelegate = UIApplication.shared.delegate as! AppDelegate
            appDelegate.accountCreation(email: email, uid: uid)
        }
    }
    
    func accountCreated() {
        DispatchQueue.main.async {
            let appDelegate = UIApplication.shared.delegate as! AppDelegate
            appDelegate.accountCreatedScreen()
        }
    }
    
    func logout() {
        DispatchQueue.main.async {
            let appDelegate = UIApplication.shared.delegate as! AppDelegate
            appDelegate.nilUser()
        }
    }
}
