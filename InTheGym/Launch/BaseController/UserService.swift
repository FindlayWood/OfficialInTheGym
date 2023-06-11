//
//  UserService.swift
//  InTheGym
//
//  Created by Findlay-Personal on 11/06/2023.
//  Copyright © 2023 FindlayWood. All rights reserved.
//

import Foundation

protocol UserService {
    func loadUser() async throws -> Users
}

extension UserService {
    func fallback(_ fallback: UserService) -> UserService {
        UserServiceWithFallback(primary: self, fallback: fallback)
    }
}

struct UserServiceWithFallback: UserService {
    var primary: UserService
    var fallback: UserService
    
    func loadUser() async throws -> Users {
        do {
            let primary = try await primary.loadUser()
            return primary
        } catch {
            return try await fallback.loadUser()
        }
    }
}

protocol ObserveUserService {
    func observeChange(completion: @escaping (Result<Users,UserStateError>) -> Void)
}

struct UserCacheServiceAdapter: UserService {
    
    func loadUser() async throws -> Users {
        if UserDefaults.currentUser == Users.nilUser {
            throw NSError(domain: "No user in UserDefaults", code: 0)
        } else {
            return UserDefaults.currentUser
        }
    }
}

struct UserAPIServiceAdapter: UserService {
    
    var authService: AuthManagerService
    var firestoreService: FirestoreService
    
    func loadUser() async throws -> Users {
        let firebaseUser = try await authService.checkForCurrentUser()
        let userModel: Users = try await firestoreService.read(at: "Users/\(firebaseUser.uid)")
        return userModel
    }
}

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

enum UserStateError: Error {
    case noUser
    case notVerified
    case noAccount(email: String, uid: String)
}


protocol CacheUserSaver {
    func save(_ user: Users)
}

struct UserDefaultsCacheUserSaver: CacheUserSaver {
    
    /// save given user model to cache - UserDefaults
    /// - Parameter user: optional user model to save - nil to remove
    func save(_ user: Users) {
        UserDefaults.currentUser = user
    }
}
