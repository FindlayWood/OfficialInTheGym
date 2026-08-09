//
//  FirebaseAccountCreationSignOut.swift
//  InTheGym
//
//  Created by Findlay Wood on 09/08/2026.
//  Copyright © 2026 FindlayWood. All rights reserved.
//

import AccountCreationKit
import Foundation

struct FirebaseAccountCreationSignOut: AccountCreationSignOutService {

    var authService: AuthManagerService = FirebaseAuthManager.shared

    func signOut() async throws {
        try authService.signout()
    }
}
