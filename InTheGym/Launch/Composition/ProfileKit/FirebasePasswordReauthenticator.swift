//
//  FirebasePasswordReauthenticator.swift
//  InTheGym
//
//  Created by Findlay Wood on 04/10/2026.
//  Copyright © 2026 FindlayWood. All rights reserved.
//
import FirebaseAuth
import ProfileKit

/// Re-authenticates the signed-in user with their password, the check before
/// anything permanent. Firebase's own errors are mapped to the few
/// `AccountDeletionError` cases the screen tells apart.
struct FirebasePasswordReauthenticator {

    func reauthenticate(password: String) async throws {
        guard let user = Auth.auth().currentUser, let email = user.email else {
            throw AccountDeletionError.failed
        }
        do {
            try await user.reauthenticate(with: EmailAuthProvider.credential(withEmail: email, password: password))
        } catch let error as NSError {
            switch AuthErrorCode.Code(rawValue: error.code) {
            case .wrongPassword, .invalidCredential, .userMismatch:
                throw AccountDeletionError.wrongPassword
            case .tooManyRequests:
                throw AccountDeletionError.tooManyAttempts
            default:
                print("❌ Reauthentication failed: \(error)")
                throw AccountDeletionError.failed
            }
        }
    }
}
