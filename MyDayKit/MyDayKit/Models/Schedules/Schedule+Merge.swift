//
//  Schedule+Merge.swift
//  MyDayKit
//
//  Created by Findlay Wood on 08/11/2026.
//

import Foundation

extension Schedule {

    /// The one rule for combining the local and remote copies, by id with the later `updatedAt`
    /// winning, as `WorkoutLibraryManager.merge` does for templates. Neither side is authoritative:
    /// local holds what has not synced, remote holds what was made on another device.
    ///
    /// **Local wins a tie.** Local files store dates to the whole second, so two edits inside one
    /// second carry the same `updatedAt`, and the local copy is the later of the two. Unlike a custom
    /// exercise, a schedule has no server field that only the remote copy could carry.
    ///
    /// **Stopped schedules stay in the result.** It is what stops an older copy of one from
    /// bringing it back.
    ///
    /// Oldest first, so the cards keep their order as schedules are edited.
    static func merged(local: [Schedule], remote: [Schedule]) -> [Schedule] {
        var byId = Dictionary(remote.map { ($0.id, $0) }, uniquingKeysWith: { first, _ in first })
        for schedule in local {
            if let existing = byId[schedule.id], existing.updatedAt > schedule.updatedAt {
                continue
            }
            byId[schedule.id] = schedule
        }
        return byId.values.sorted { first, second in
            first.createdAt == second.createdAt ? first.id < second.id : first.createdAt < second.createdAt
        }
    }
}
