//
//  BodyPartsLoader.swift
//  DiscoverKit
//
//  Created by Findlay Wood on 25/10/2026.
//

import Foundation

/// The muscle groups and movement patterns to name and offer. The app answers
/// it from the same readers MyDay's custom exercise form uses — one reader per
/// collection, cached on disk.
public protocol BodyPartsLoader {
    func loadBodyParts() async throws -> DiscoverBodyParts
}
