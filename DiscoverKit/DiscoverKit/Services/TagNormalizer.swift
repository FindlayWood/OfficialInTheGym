//
//  TagNormalizer.swift
//  DiscoverKit
//
//  Created by Findlay Wood on 30/09/2026.
//

import Foundation

/// The app's one rule for what a tag may contain, applied as the user types.
///
/// A protocol rather than a copy of the rule: MyDayKit's `WorkoutTag.normalized`
/// is the definition, and a second one here would drift from it — the server
/// indexes only tags that pass its matching check, so a drifted client would
/// let users apply tags that silently never appear.
public protocol TagNormalizer {
    var maxLength: Int { get }
    func normalized(_ raw: String) -> String
}
