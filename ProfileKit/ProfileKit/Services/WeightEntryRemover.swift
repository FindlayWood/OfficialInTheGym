//
//  WeightEntryRemover.swift
//  ProfileKit
//
//  Created by Findlay Wood on 03/10/2026.
//
import Foundation

/// Deletes one weight entry, by its `yyyy-MM-dd` id.
public protocol WeightEntryRemover {
    func remove(entryId: String) async throws
}
