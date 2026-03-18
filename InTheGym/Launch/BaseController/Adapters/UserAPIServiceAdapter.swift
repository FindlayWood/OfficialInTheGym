//
//  UserAPIServiceAdapter.swift
//  InTheGym
//
//  Created by Findlay-Personal on 13/06/2023.
//  Copyright © 2023 FindlayWood. All rights reserved.
//

import Foundation

struct UserAPIServiceAdapter: UserLoader {
    
    var authService: AuthManagerService
    var firestoreService: FirestoreService
    
    func loadUser() async -> Result<Users,UserStateError> {
        if let firebaseUser = try? await authService.checkForCurrentUser() {
            if let userModel: Users = try? await firestoreService.read(at: "Users/\(firebaseUser.uid)") {
                return .success(userModel)
            } else {
                if firebaseUser.isEmailVerified {
                    guard let email = firebaseUser.email else {
                        return .failure(.noUser)
                    }
                    return .failure(.noAccount(email: email, uid: firebaseUser.uid))
                } else {
                    return .failure(.notVerified)
                }
            }
        }
        return .failure(.noUser)
    }
}
