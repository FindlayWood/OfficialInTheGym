//
//  UserAPIServiceAdapter.swift
//  InTheGym
//
//  Created by Findlay-Personal on 13/06/2023.
//  Copyright © 2023 FindlayWood. All rights reserved.
//

import Foundation

struct UserAPIServiceAdapter: UserService {
    
    var authService: AuthManagerService
    var firestoreService: FirestoreService
    
    func loadUser() async throws -> Users {
        let firebaseUser = try await authService.checkForCurrentUser()
        let userModel: Users = try await firestoreService.read(at: "Users/\(firebaseUser.uid)")
        return userModel
    }
}
