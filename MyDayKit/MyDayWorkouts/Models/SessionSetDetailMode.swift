//
//  SessionSetDetailMode.swift
//  MyDayKit
//
//  Created by Findlay Wood on 06/08/2026.
//

import Foundation

/// Which of the three questions `SessionSetDetailOverlay` is answering. The
/// overlay is reachable in every session state — a set is worth reading before
/// it is performed and after — but it is answering a different question each
/// time, so the same card shows a different number.
///
/// This replaced a single `isSessionActive: Bool`, which could not tell
/// `.planned` from `.review` and so rendered an unstarted set as "—": the
/// prescription is the whole point of looking before you start.
enum SessionSetDetailMode {

    /// Not started. Shows the prescription as the value — what to do.
    case planned

    /// In progress. Values are editable, with the target beside them.
    case active

    /// Finished. Shows what was performed, and "—" for a set never logged.
    case review

    /// Only an in-progress session accepts input.
    var isEditable: Bool { self == .active }

    init(isStarted: Bool, isCompleted: Bool) {
        if !isStarted {
            self = .planned
        } else if isCompleted {
            self = .review
        } else {
            self = .active
        }
    }
}
