//
//  DiscoverReportTarget+Firestore.swift
//  InTheGym
//
//  Created by Findlay Wood on 30/09/2026.
//  Copyright © 2026 FindlayWood. All rights reserved.
//

import DiscoverKit
import Foundation

/// **The one definition of how a report names its target.** `targetPath` is the
/// reported thing's own path and `targetKind` its kind — the pair the
/// `discoverReportFiled` function validates against one path shape per kind,
/// so these must stay in step with `Moderation/ReportTarget.ts`.
extension DiscoverReportTarget {

    var targetPath: String {
        switch self {
        case let .comment(commentId, subject): return subject.commentPath(commentId)
        case .workout(let id): return DiscoverSubject.workout(id: id).documentPath
        case .clip(let id): return DiscoverSubject.clip(id: id).documentPath
        case .tag(let tag): return "\(DiscoverTagPath.tags)/\(tag)"
        }
    }

    var targetKind: String {
        switch self {
        case .comment: return "comment"
        case .workout: return "workout"
        case .clip: return "clip"
        case .tag: return "tag"
        }
    }

    /// The target a stored report names — how the user's own past reports are
    /// read back. Nil for anything that is not one of the four shapes.
    init?(targetPath: String, targetKind: String) {
        let parts = targetPath.split(separator: "/").map(String.init)
        switch (targetKind, parts.count) {
        case ("comment", 4) where parts[2] == "Comments":
            let subject: DiscoverSubject
            switch parts[0] {
            case "Exercises": subject = .exercise(id: parts[1])
            case "WorkoutTemplates": subject = .workout(id: parts[1])
            case "Clips": subject = .clip(id: parts[1])
            default: return nil
            }
            self = .comment(commentId: parts[3], subject: subject)
        case ("workout", 2) where parts[0] == "WorkoutTemplates":
            self = .workout(id: parts[1])
        case ("clip", 2) where parts[0] == "Clips":
            self = .clip(id: parts[1])
        case ("tag", 2) where parts[0] == DiscoverTagPath.tags:
            self = .tag(parts[1])
        default:
            return nil
        }
    }
}
