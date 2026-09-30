//
//  Date+DiscoverAge.swift
//  DiscoverKit
//
//  Created by Findlay Wood on 30/09/2026.
//

import Foundation

extension Date {

    /// How long ago, as a comment row shows it: `now`, `5m`, `3h`, `2d`, then
    /// the date. Short because it sits beside a name on one line.
    var discoverAge: String {
        let seconds = Date().timeIntervalSince(self)
        switch seconds {
        case ..<60: return "now"
        case ..<3_600: return "\(Int(seconds / 60))m"
        case ..<86_400: return "\(Int(seconds / 3_600))h"
        case ..<604_800: return "\(Int(seconds / 86_400))d"
        default: return formatted(.dateTime.day().month(.abbreviated))
        }
    }
}
