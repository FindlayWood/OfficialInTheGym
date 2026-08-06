//
//  SessionSetEditTarget.swift
//  MyDayKit
//
//  Created by Findlay Wood on 06/08/2026.
//

import Foundation

/// What the set detail overlay is currently editing, and therefore which sheet
/// it presents. One `Identifiable` covering all three routes, because a single
/// `.sheet(item:)` is the only reliable way to drive several sheets from one view.
enum SessionSetEditTarget: Identifiable, Hashable {
    case measure(SessionSetMeasure)
    case tempo
    case note

    var id: String {
        switch self {
        case .measure(let measure): return measure.rawValue
        case .tempo:                return "tempo"
        case .note:                 return "note"
        }
    }

    /// The note sheet sizes itself around the system keyboard; the other two
    /// stand the `CustomNumberPad` up and need the height for it.
    var detentHeight: CGFloat {
        switch self {
        case .measure(let measure): return measure == .weight ? 620 : 560
        case .tempo:                return 620
        case .note:                 return 400
        }
    }
}
