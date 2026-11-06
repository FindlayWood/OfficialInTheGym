//
//  RPEScale.swift
//  MyDayKit
//
//  Created by Findlay Wood on 05/11/2026.
//

import SwiftUI

/// **The one colour scale for an RPE score in MyDay**: easy blue, moderate green, hard amber,
/// maximal red, on the matte palette. `RPECard` had it privately, and the sport session screen
/// carried its own on system green / orange / red with a hand-mixed dark red for 9–10 — so the
/// same 7 read amber on the day's rating and red on a game. Both read it from here now.
///
/// The workout session's RPE sheets and the Fitness screen still have their own; they move here
/// when they are next touched.
enum RPEScale {
    static func color(for score: Int) -> Color {
        switch score {
        case 1...3:  return .matteBlue
        case 4...6:  return .matteGreen
        case 7...8:  return .matteAmber
        case 9...10: return .matteRed
        default:     return .gray
        }
    }
}
