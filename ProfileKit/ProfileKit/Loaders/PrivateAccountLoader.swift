//
//  PrivateAccountLoader.swift
//  ProfileKit
//
//  Created by Findlay Wood on 04/10/2026.
//
import Foundation

/// Whether the signed-in user's account is private (`Users.isPrivate`).
public protocol PrivateAccountLoader {
    func isPrivate() async throws -> Bool
}
