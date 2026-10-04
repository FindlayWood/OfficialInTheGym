//
//  PreviewAccountServices.swift
//  ProfileKit
//
//  Created by Findlay Wood on 03/10/2026.
//
import Foundation

/// Preview conformer for signing out and password reset. Both succeed and do
/// nothing.
public final class PreviewAccountServices: ProfileSignOutService, PasswordResetService, @unchecked Sendable {
    public init() {}

    public func signOut() async throws {}

    public func sendPasswordReset() async throws {}
}
