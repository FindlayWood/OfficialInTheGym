//
//  MovementPattern.swift
//  StatsKit
//
//  Created by Findlay Wood on 13/04/2026.
//

import SwiftUI

public struct MovementPattern: Decodable {
    public let id: String
    public let name: String
}

public extension MovementPattern {
    /// **The one definition of how a raw pattern id is shown and coloured.**
    /// `TrainingBalanceData` carries patterns as the ids they are stored under
    /// (`"horizontal_push"`), so every screen that shows one has to turn it into
    /// words and pick a colour for it. Both rules had been written out twice
    /// inside `TrainingBalanceScreen` — once in `MovementPatternBreakdown` and
    /// once in `MovementPatternProgressionChart` — and the copies had already
    /// drifted: the palette sweep onto the matte colours caught one and left the
    /// other on `.orange` / `.blue` / `.purple`, so the same pattern was a
    /// different colour on the distribution bars and on its own chart. The name
    /// existed in a third place as an inline `replacingOccurrences`.
    static func displayName(for pattern: String) -> String {
        pattern.replacingOccurrences(of: "_", with: " ").capitalized
    }

    /// Matte, like every signal colour on the stats path — these sit beside
    /// `MiniLineChart`s drawn in the matte set, and a sharp accent next to them
    /// reads as a system alert rather than a category. The colour identifies a
    /// pattern, as `ExerciseCategory.color` does; it says nothing about whether
    /// the volume in it is good.
    static func color(for pattern: String) -> Color {
        let lower = pattern.lowercased()
        if lower.contains("push") || lower.contains("press") { return .matteAmber }
        if lower.contains("pull") || lower.contains("row") { return .matteBlue }
        if lower.contains("squat") || lower.contains("lunge") { return .mattePlum }
        if lower.contains("hinge") { return .matteGreen }
        return .gray
    }
}
