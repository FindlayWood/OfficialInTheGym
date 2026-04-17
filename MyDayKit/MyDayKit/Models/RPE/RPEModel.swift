//
//  RPEModel.swift
//  MyDayKit
//
//  Created by Findlay Wood on 17/04/2026.
//

import Foundation

// MARK: - RPEEntry
public struct RPEEntry: Identifiable {
    public let id: String
    public let date: Date
    public let score: Int  // 1–10

    public init(id: String = UUID().uuidString, date: Date = .now, score: Int) {
        self.id = id
        self.date = date
        self.score = max(1, min(10, score))
    }

    public var label: String {
        switch score {
        case 1...2:  return "Very Light"
        case 3...4:  return "Light"
        case 5...6:  return "Moderate"
        case 7...8:  return "Hard"
        case 9:      return "Very Hard"
        case 10:     return "Maximum"
        default:     return ""
        }
    }

    public var color: RPEColor {
        switch score {
        case 1...3:  return .low
        case 4...6:  return .moderate
        case 7...8:  return .high
        case 9...10: return .maximum
        default:     return .moderate
        }
    }
}

// MARK: - RPEColor
public enum RPEColor {
    case low, moderate, high, maximum

    public var swiftUIColor: some Hashable {
        // Returned as string key to avoid importing SwiftUI here
        // Resolved in the view layer
        self
    }
}
