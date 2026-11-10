//
//  InjurySide.swift
//  MyDayKit
//
//  Created by Findlay Wood on 10/11/2026.
//

import Foundation

/// Which side, for a region that has one (`InjuryRegion.hasSide`). Stored as its raw value.
public enum InjurySide: String, CaseIterable, Codable, Hashable, Sendable {
    case left
    case right
    case both

    var title: String {
        switch self {
        case .left: return "Left"
        case .right: return "Right"
        case .both: return "Both"
        }
    }
}
