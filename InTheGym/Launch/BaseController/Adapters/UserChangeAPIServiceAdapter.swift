//
//  UserChangeAPIServiceAdapter.swift
//  InTheGym
//
//  Created by Findlay-Personal on 13/06/2023.
//  Copyright © 2023 FindlayWood. All rights reserved.
//

import Foundation

struct UserChangeAPIServiceAdapter: ObserveUserService {
    
    var authService: AuthManagerService
    var firestoreService: FirestoreService
    
    func observeChange(completion: @escaping (Result<Users,UserStateError>) -> Void) {
        authService.observeCurrentUser { auth, user in
            guard let user else {
                completion(.failure(.noUser))
                return
            }
            guard let email = user.email
            else {
                completion(.failure(.noUser))
                return
            }
            if user.isEmailVerified {
                loadUserModel(with: email, from: user.uid, completion: completion)
            } else {
                completion(.failure(.notVerified))
            }
        }
    }
    
    private func loadUserModel(with email: String, from uid: String, completion: @escaping (Result<Users,UserStateError>) -> Void) {
        Task {
            do {
                let userModel: Users = try await firestoreService.read(at: "Users/\(uid)")
                completion(.success(userModel))
            } catch {
                completion(.failure(.noAccount(email: email, uid: uid)))
            }
        }
    }
}
