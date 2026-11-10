//
//  InjuryPainColor.swift
//  StatsKit
//
//  Created by Findlay Wood on 10/11/2026.
//

import SwiftUI

/// The colour of a pain score — **StatsKit's copy of `InjuryPainScale.color(for:)` in MyDayKit;
/// keep the two in step**, or a 5 rated amber on MyDay reads red on its chart.
enum InjuryPainColor {
    static func color(for pain: Int) -> Color {
        switch pain {
        case ..<4: return .matteGreen
        case 4..<7: return .matteAmber
        default: return .matteRed
        }
    }
}
