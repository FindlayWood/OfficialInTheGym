//
//  DiscoverReportReason.swift
//  DiscoverKit
//
//  Created by Findlay Wood on 30/09/2026.
//

import Foundation

/// Why something is being reported — a fixed list, never free text, so a
/// report cannot itself carry abuse and every report can be triaged the same
/// way. The raw values are what the server stores; the rules accept only these.
public enum DiscoverReportReason: String, CaseIterable, Identifiable, Sendable {
    case spam
    case harassment
    case hate
    case sexual
    case violence
    case other

    public var id: String { rawValue }

    var title: String {
        switch self {
        case .spam: return "Spam or misleading"
        case .harassment: return "Harassment or bullying"
        case .hate: return "Hate speech"
        case .sexual: return "Sexual content"
        case .violence: return "Violence or dangerous acts"
        case .other: return "Something else"
        }
    }
}
