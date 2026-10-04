//
//  PasswordResetService.swift
//  ProfileKit
//
//  Created by Findlay Wood on 03/10/2026.
//
import Foundation

/// Sends the signed-in user a password-reset email. The address is the
/// adapter's business: ProfileKit never holds the user's email (see
/// `ProfileHeader`).
public protocol PasswordResetService {
    func sendPasswordReset() async throws
}
