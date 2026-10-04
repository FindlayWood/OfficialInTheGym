//
//  PreviewAccountDeleter.swift
//  ProfileKit
//
//  Created by Findlay Wood on 04/10/2026.
//
import Foundation

/// Preview conformer: "wrong" is the wrong password, anything else succeeds.
public final class PreviewAccountDeleter: AccountDeleter, @unchecked Sendable {
    public init() {}

    public func deleteAccount(password: String) async throws {
        if password == "wrong" { throw AccountDeletionError.wrongPassword }
    }
}
