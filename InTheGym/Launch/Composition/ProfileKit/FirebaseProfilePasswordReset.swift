//
//  FirebaseProfilePasswordReset.swift
//  InTheGym
//
//  Created by Findlay Wood on 03/10/2026.
//  Copyright © 2026 FindlayWood. All rights reserved.
//
import ProfileKit

/// Sends the reset email to the signed-in user's address. The address is
/// injected from the composition root, so ProfileKit never holds it.
struct FirebaseProfilePasswordReset: PasswordResetService {

    let email: String
    var authService: AuthManagerService = FirebaseAuthManager.shared

    func sendPasswordReset() async throws {
        try await authService.forgotPassword(for: email)
    }
}
