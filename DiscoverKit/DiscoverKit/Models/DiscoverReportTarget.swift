//
//  DiscoverReportTarget.swift
//  DiscoverKit
//
//  Created by Findlay Wood on 30/09/2026.
//

import Foundation

/// Something a user can report: a comment, a public workout, a clip, or a tag.
/// Exercises are not reportable — they are the app's own catalogue.
///
/// `@frozen` for the reason `DiscoverSubject` is.
@frozen
public enum DiscoverReportTarget: Hashable, Sendable {
    case comment(commentId: String, subject: DiscoverSubject)
    case workout(id: String)
    case clip(id: String)
    case tag(String)

    var noun: String {
        switch self {
        case .comment: return "comment"
        case .workout: return "workout"
        case .clip: return "clip"
        case .tag: return "tag"
        }
    }
}
