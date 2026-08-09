//
//  UsernameReserver.swift
//  AccountCreationKit
//
//  Created by Findlay Wood on 09/08/2026.
//

import Foundation

public protocol UsernameReserver {
    /// Claims the username for this user. Throwing means the username was not claimed.
    func reserveUsername(_ username: String, for uid: String) async throws
}
