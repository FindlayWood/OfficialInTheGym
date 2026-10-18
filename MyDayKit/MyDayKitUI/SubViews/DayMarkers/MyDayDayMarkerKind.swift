//
//  MyDayDayMarkerKind.swift
//  MyDayKit
//
//  Created by Findlay Wood on 17/10/2026.
//

import SwiftUI

/// The three things the date strip marks, in the order a day goes: check in, train, rate it.
/// **The order is the slot.** Each kind always draws in the same position inside a pill, and an
/// absent one leaves its slot empty rather than closing the gap, so a dot means the same thing
/// on every day and a run of days can be read down a column.
///
/// The colours are the cards' own — the check-in card is `matteGreen`, the RPE card
/// `matteAmber` — so the dot and the card it stands for are recognisably the same thing. They are semantic, like
/// `ExerciseCategory`'s, not accents. Exercise is `darkColor` because logging *is* the screen's
/// accent; on a `darkColor` surface — the selected pill, the MyDay page — it turns white.
enum MyDayDayMarkerKind: CaseIterable {
    case checkIn
    case exercise
    case rpe

    var title: String {
        switch self {
        case .checkIn: "Check-in"
        case .exercise: "Exercise"
        case .rpe: "RPE"
        }
    }

    func color(onBrandSurface: Bool) -> Color {
        switch self {
        case .checkIn: .matteGreen
        case .exercise: onBrandSurface ? .white : .darkColor
        case .rpe: .matteAmber
        }
    }

    func isPresent(in markers: MyDayDayMarkers) -> Bool {
        switch self {
        case .checkIn: markers.hasCheckIn
        case .exercise: markers.hasExercise
        case .rpe: markers.hasRPE
        }
    }
}
