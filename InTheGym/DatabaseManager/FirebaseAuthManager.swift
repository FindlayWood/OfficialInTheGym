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
import CodableFirebase

enum loginError: Error {
    case emailNotVerified(User)
    case invalidCredentials
    case unKnown
}

protocol AuthManagerService {
    func createNewUser(with user: SignUpUserModel, completion: @escaping (Result<Void,SignUpError>) -> Void)
    func checkUsernameIsUnique(for username:String, completion: @escaping (Bool) -> ())
    func checkForCurrentUser(completion: @escaping (Result<User, checkingForUserError>) -> Void)
    func loginUser(with loginModel: LoginModel, completion: @escaping (Result<Users, loginError>) -> Void)
    func resendEmailVerification(to user: User, completion: @escaping (Bool) -> Void)
    func sendResetPassword(to email: String, completion: @escaping (Bool) -> Void)
    func logout(completion: @escaping (Bool) -> Void)
}

class FirebaseAuthManager: AuthManagerService {
    
    static let shared = FirebaseAuthManager()
    static var currentlyLoggedInUser: Users!
    
    private init(){}
    
    // MARK: - Create User
    func createNewUser(with user: SignUpUserModel, completion: @escaping (Result<Void,SignUpError>) -> Void) {
        Auth.auth().createUser(withEmail: user.email, password: user.password) { [weak self] AuthResult, error in
            guard let self = self else {return}
            if let error = error {
                let error = error as NSError
                switch error.code {
                case AuthErrorCode.emailAlreadyInUse.rawValue:
                    completion(.failure(.emailTaken))
                case AuthErrorCode.invalidEmail.rawValue:
                    completion(.failure(.invalidEmail))
                default:
                    completion(.failure(.unknown))
                }
            } else  {
                guard let newUserID = AuthResult?.user.uid else {return}
                let newUser = Users(admin: user.admin,
                                    email: user.email,
                                    username: user.username,
                                    firstName: user.firstName,
                                    lastName: user.lastName,
                                    uid: newUserID,
                                    accountCreated: Date().timeIntervalSince1970)
                self.addUserToDatabase(user: newUser, completion: completion)
            }
        }
    }
    
    func addUserToDatabase(user: Users, completion: @escaping (Result<Void,SignUpError>) -> Void) {
        let userID = user.uid
        let dbref = Database.database().reference()
        var newUserData = Dictionary<String,Any>()
        do {
            let object = try FirebaseEncoder().encode(user)
            newUserData["users/\(userID)"] = object
            newUserData["Usernames/\(user.username)"] = true
            dbref.updateChildValues(newUserData) { error, _ in
                if error != nil {
                    completion(.failure(.unknown))
                } else {
                    completion(.success(()))
                }
            }
        }
        catch {
            completion(.failure(.unknown))
        }
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



