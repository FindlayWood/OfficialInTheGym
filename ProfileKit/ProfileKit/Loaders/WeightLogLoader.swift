//
//  WeightLogLoader.swift
//  ProfileKit
//
//  Created by Findlay Wood on 03/10/2026.
//
import Foundation

/// Loads the signed-in user's most recent weight entries, **newest first**.
public protocol WeightLogLoader {
    func load(limit: Int) async throws -> [WeightEntry]
}
