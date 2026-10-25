//
//  DiscoverBodyPart.swift
//  DiscoverKit
//
//  Created by Findlay Wood on 25/10/2026.
//

import Foundation

/// One muscle group or movement pattern: the id an exercise stores, and the
/// name to show. **Names come from the `MuscleGroups` / `MovementTypes`
/// documents, never from prettifying an id** — `push_horizontal` is not a
/// name, and the two lists are where curators decide what each is called.
public struct DiscoverBodyPart: Identifiable, Hashable, Sendable {
    public let id: String
    public let name: String

    public init(id: String, name: String) {
        self.id = id
        self.name = name
    }
}
