//
//  Unfollower.swift
//  ProfileKit
//
//  Created by Findlay Wood on 04/10/2026.
//
import Foundation

/// Stops following someone, or withdraws a request not yet approved. Both are
/// the same delete of the signed-in user's follow document.
public protocol Unfollower {
    func unfollow(_ userId: String) async throws
}
