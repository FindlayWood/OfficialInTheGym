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

enum loginError: Error {
    case emailNotVerified(User)
    case invalidCredentials
    case unKnown
}

protocol AuthManagerService {
    
    func login(with email: String, password: String) async throws
    func signup(with email: String, password: String) async throws
    func forgotPassword(for email: String) async throws
    func sendEmailVerification() async throws
    func checkForCurrentUser() async throws -> User
    func observeCurrentUser(completion: @escaping (Auth, User?) -> Void)
    func signout() throws
}

class FirebaseAuthManager: AuthManagerService {
    
    static let shared = FirebaseAuthManager()
    static var currentlyLoggedInUser: Users!
    
    private init(){}
    
    
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
    func observeCurrentUser(completion: @escaping (Auth, User?) -> Void) {
        Auth.auth().addStateDidChangeListener(completion)
    }

    func checkForCurrentUser() async throws -> User {
        if let currentUser = Auth.auth().currentUser {
            try await currentUser.reload()
            return currentUser
        } else {
            throw NSError(domain: "No user", code: 0)
        }
    }
}



