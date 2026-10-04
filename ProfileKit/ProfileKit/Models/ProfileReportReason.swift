//
//  ProfileReportReason.swift
//  ProfileKit
//
//  Created by Findlay Wood on 04/10/2026.
//
import Foundation

/// Why a profile is being reported: a fixed list, never free text, as with
/// every report (Apple guideline 1.2, and nothing to moderate inside the
/// report itself).
///
/// **ProfileKit's copy of DiscoverKit's `DiscoverReportReason`, kept in step
/// with it.** The raw values are the `Reports` create rule's accepted
/// `reason` list, shared by every report kind. A value one side has and the
/// other does not is a report the rules refuse.
public enum ProfileReportReason: String, CaseIterable, Identifiable, Sendable {
    case spam
    case harassment
    case hate
    case sexual
    case violence
    case other

    public var id: String { rawValue }

    var title: String {
        switch self {
        case .spam: "Spam or misleading"
        case .harassment: "Harassment or bullying"
        case .hate: "Hate speech"
        case .sexual: "Sexual content"
        case .violence: "Violence or dangerous acts"
        case .other: "Something else"
        }
    }
}
