//
//  ProfileBlockStatusLoader.swift
//  ProfileKit
//
//  Created by Findlay Wood on 04/10/2026.
//
import Foundation

/// Whether the signed-in user has blocked someone. Only your own blocks are
/// readable. Whether someone has blocked *you* is theirs, and the app cannot
/// know it. The `Follows` rules simply refuse a follow either way.
public protocol ProfileBlockStatusLoader {
    func hasBlocked(_ userId: String) async throws -> Bool
}
