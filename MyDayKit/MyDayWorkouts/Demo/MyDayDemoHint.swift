//
//  MyDayDemoHint.swift
//  MyDayKit
//
//  Created by Findlay Wood on 18/10/2026.
//

import Foundation

/// The demo's next-step hint, read off the session as it stands.
///
/// Each step names the one gesture the screen does not explain itself, in the
/// order someone meets them: start, the pill's circle (quick-complete — the
/// fastest way to log, and nothing on screen says it exists), the pill itself
/// (the overlay, where numbers change), Add Set, then Finish. **Derived, not
/// stored** — un-logging a set walks the hint back with it, and there is no
/// tutorial state to fall out of step with the screen.
///
/// Add Set is suggested only while nothing has been added, and only for a
/// couple of logs: past that it would nag someone who just wants to finish.
enum MyDayDemoHint {

    static let detail = "Example workout · nothing you log is saved"

    static func notice(for manager: WorkoutSessionManager, initialSetCount: Int) -> WorkoutSessionNotice {
        WorkoutSessionNotice(text: text(for: manager, initialSetCount: initialSetCount), detail: detail)
    }

    private static func text(for manager: WorkoutSessionManager, initialSetCount: Int) -> String {
        switch manager.sessionStatus {
        case .notStarted:
            return "Tap Start Workout when you're ready"
        case .completed:
            return "Workout complete"
        case .inProgress:
            let logged = manager.totalSetsLogged
            let hasAddedSet = manager.totalSetsTargeted > initialSetCount
            switch logged {
            case 0:
                return "Tap a set's circle to log it as written"
            case 1:
                return "Tap a set to see it in full or change the numbers"
            case 2...3 where !hasAddedSet:
                return "Want one more? Tap Add Set under any exercise"
            default:
                return "Tap Finish Workout whenever you're done"
            }
        }
    }
}
