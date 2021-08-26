//
//  FirebaseAuthManager.swift
//  InTheGym
//
//  Created by Findlay Wood on 06/05/2021.
//  Copyright © 2021 FindlayWood. All rights reserved.
//

import Foundation
import Firebase

class FirebaseAuthManager: AuthManagerService {
    
    static let shared = FirebaseAuthManager()
    static var currentlyLoggedInUser: Users!
    
    private init(){}
    
    func createNewUser(with user: SignUpUserModel, completion: @escaping (Bool) -> Void) {
        Auth.auth().createUser(withEmail: user.email, password: user.password) { user, error in
            if let error = error{
                completion(false)
                print(error.localizedDescription)
                return
            } else  {
                completion(true)
            }
        }
    }
    
    func addUserToDatabase(with userModel: SignUpUserModel, authUser: User, completion: @escaping (Bool) -> Void) {
        let userID = authUser.uid
        let object = userModel.toObject()
        let ref = Database.database().reference().child("users").child(userID)
        ref.setValue(object)
    }
    
    func loginUser(with email: String, and password: String, completion: @escaping (Result<User, Error>) -> Void) {
        Auth.auth().signIn(withEmail: email, password: password) { AuthResult, error in
            if let error = error {
                print(error.localizedDescription)
                completion(.failure(error))
            } else {
                if let user = AuthResult?.user {
                    completion(.success(user))
                } else {
                    return
                }
            }
        }
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
}

protocol AuthManagerService {
    func createNewUser(with user: SignUpUserModel, completion: @escaping (Bool) -> Void)
    func loginUser(with email: String, and password: String, completion: @escaping (Result<User, Error>) -> Void)
}

class MockAuthManager: AuthManagerService {
    static let shared = MockAuthManager()
    
    private init(){}
    
    var ApiService: AuthManagerService!
    
    func createNewUser(with user: SignUpUserModel, completion: @escaping (Bool) -> Void) {
        completion(true)
    }
    
    func loginUser(with email: String, and password: String, completion: @escaping (Result<User, Error>) -> Void) {
        
    }
    
    
}
