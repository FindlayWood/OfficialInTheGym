//
//  UsernameAvailabilityChecker.swift
//  AccountCreationKit
//
//  Created by Findlay Wood on 09/08/2026.
//

import Foundation

public protocol UsernameAvailabilityChecker {
    /// `true` when no account has claimed this username yet.
    func isUsernameAvailable(_ username: String) async throws -> Bool
}
