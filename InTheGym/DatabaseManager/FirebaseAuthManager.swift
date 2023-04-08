//
//  FirebaseAuthManager.swift
//  InTheGym
//
//  Created by Findlay Wood on 06/05/2021.
//  Copyright © 2021 FindlayWood. All rights reserved.
//

import Foundation
import Firebase
import Network
//import CodableFirebase

enum loginError: Error {
    case emailNotVerified(User)
    case invalidCredentials
    case unKnown
}

protocol AuthManagerService {
    func checkUsernameIsUnique(for username:String, completion: @escaping (Bool) -> ())
    func checkForCurrentUser(completion: @escaping (Result<User, checkingForUserError>) -> Void)
    func loginUser(with loginModel: LoginModel, completion: @escaping (Result<Users, loginError>) -> Void)
    func resendEmailVerification(to user: User, completion: @escaping (Bool) -> Void)
    func sendResetPassword(to email: String, completion: @escaping (Bool) -> Void)
    func logout(completion: @escaping (Bool) -> Void)
    
    // MARK: - Async
    func loginAsync(with loginModel: LoginModel) async throws -> Users
    func createNewUserAsync(with user: SignUpUserModel) async throws
    
    func login(with email: String, password: String) async throws
    func signup(with email: String, password: String) async throws
    func forgotPassword(for email: String) async throws
    func sendEmailVerification() async throws
    func signout() throws
}

class FirebaseAuthManager: AuthManagerService {
    
    static let shared = FirebaseAuthManager()
    static var currentlyLoggedInUser: Users!
    
    private init(){}
    
    // MARK: - Create User
//    func createNewUser(with user: SignUpUserModel, completion: @escaping (Result<Void,SignUpError>) -> Void) {
//        Auth.auth().createUser(withEmail: user.email, password: user.password) { [weak self] AuthResult, error in
//            guard let self = self else {return}
//            if let error = error {
//                let error = error as NSError
//                switch error.code {
//                case AuthErrorCode.emailAlreadyInUse.rawValue:
//                    completion(.failure(.emailTaken))
//                case AuthErrorCode.invalidEmail.rawValue:
//                    completion(.failure(.invalidEmail))
//                default:
//                    completion(.failure(.unknown))
//                }
//            } else  {
//                guard let newUserID = AuthResult?.user.uid else {return}
//                let newUser = Users(admin: user.admin,
//                                    email: user.email,
//                                    username: user.username,
//                                    firstName: user.firstName,
//                                    lastName: user.lastName,
//                                    uid: newUserID,
//                                    accountCreated: Date().timeIntervalSince1970)
//                self.addUserToDatabase(user: newUser, completion: completion)
//            }
//        }
//    }
    
    // MARK: - Create User Async
    func createNewUserAsync(with user: SignUpUserModel) async throws {
        let authResult = try await Auth.auth().createUser(withEmail: user.email, password: user.password)
        try await authResult.user.sendEmailVerification()
        let newUserID = authResult.user.uid
        let newUser = Users(admin: user.admin, email: user.email, username: user.username, firstName: user.firstName, lastName: user.lastName, uid: newUserID, accountCreated: Date().timeIntervalSince1970)
        try await addUserToDatabaseAsync(user: newUser)
    }
    
    func addUserToDatabaseAsync(user: Users) async throws {
        let dbref = Database.database().reference().child("users").child(user.uid)
        try dbref.setValue(from: user)
        let userNameRef = Database.database().reference().child("Usernames").child(user.username)
        try await userNameRef.setValue(true)
    }
    
    
    //MARK: - Checking username is unique
    func checkUsernameIsUnique(for username:String, completion: @escaping (Bool) -> ()) {
        let ref = Database.database().reference().child("Usernames").child(username)
        ref.observeSingleEvent(of: .value) { (snapshot) in
            if snapshot.exists(){
                completion(false)
            } else {
                completion(true)
            }
        }
    }
    
    // TODO: - Use loginModel
    // TODO: - Return userModel (not firebase user)
    // TODO: - Update currentlyloggedinuser
    // TODO: - Return appropriate error
    func loginUser(with loginModel: LoginModel, completion: @escaping (Result<Users, loginError>) -> Void) {
        Auth.auth().signIn(withEmail: loginModel.email, password: loginModel.password) { AuthResult, error in
            if let error = error {
                let error = error as NSError
                switch error.code {
                case AuthErrorCode.userNotFound.rawValue:
                    completion(.failure(.invalidCredentials))
                case AuthErrorCode.invalidEmail.rawValue:
                    completion(.failure(.invalidCredentials))
                default:
                    completion(.failure(.unKnown))
                }
            } else {
                if let user = AuthResult?.user {
                    switch user.isEmailVerified {
                    case true:
                        UserIDToUser.transform(userID: user.uid) { userModel in
                            FirebaseAuthManager.currentlyLoggedInUser = userModel
                            UserDefaults.currentUser = userModel
                            ViewController.username = userModel.username /// depreciated
                            ViewController.admin = userModel.admin /// depreciated
                            completion(.success(userModel))
                        }
                    case false:
                        completion(.failure(.emailNotVerified(user)))
                    }
                } else {
                    return
                }
            }
        }
    }
    
    func login(with email: String, password: String) async throws {
        try await Auth.auth().signIn(withEmail: email, password: password)
    }
    func signup(with email: String, password: String) async throws {
        let authResult = try await Auth.auth().createUser(withEmail: email, password: password)
        try await authResult.user.sendEmailVerification()
    }
    func forgotPassword(for email: String) async throws {
        try await Auth.auth().sendPasswordReset(withEmail: email)
    }
    func sendEmailVerification() async throws {
        try await Auth.auth().currentUser?.sendEmailVerification()
    }
    func signout() throws {
        try Auth.auth().signOut()
    }
    // MARK: - Login Async
    func loginAsync(with loginModel: LoginModel) async throws -> Users {
        let authResult = try await Auth.auth().signIn(withEmail: loginModel.email, password: loginModel.password)
        let user = authResult.user
        if user.isEmailVerified {
            let searchModel = UserSearchModel(uid: user.uid)
            let userModel = try await UsersLoaderAsync.shared.load(from: searchModel)
            FirebaseAuthManager.currentlyLoggedInUser = userModel
            UserDefaults.currentUser = userModel
            return userModel
        } else {
            throw loginError.emailNotVerified(user)
        }
    }
    
    // MARK: - Verify Email
    func resendEmailVerification(to user: User, completion: @escaping (Bool) -> Void) {
        user.sendEmailVerification { error in
            if let error = error {
                print(error.localizedDescription)
                completion(false)
            } else {
                completion(true)
            }
        }
    }
    
    // MARK: - Reset Password
    func sendResetPassword(to email: String, completion: @escaping (Bool) -> Void) {
        Auth.auth().sendPasswordReset(withEmail: email) { error in
            if error != nil {
                completion(false)
            } else {
                completion(true)
            }
        }
    }
    
    // MARK: - Sign In
    func signIn(completion: @escaping (Result<Void,Error>) -> Void) {
        
    }
    
    func checkForCurrentUser(completion: @escaping (Result<User, checkingForUserError>) -> Void) {
        if let currentUser = Auth.auth().currentUser {
            currentUser.reload { error in
                if error != nil {
                    completion(.failure(.reloadError))
                } else {
                    switch currentUser.isEmailVerified {
                    case true:
                        completion(.success(currentUser))
                    case false:
                        completion(.failure(.notVerified(currentUser)))
                    }
                }
            }
        } else {
            completion(.failure(.noUser))
        }
        
    }
    // MARK: - Logout
    func logout(completion: @escaping (Bool) -> Void) {
        do {
            try Auth.auth().signOut()
            completion(true)
        } catch {
            completion(false)
        }
    }
}



