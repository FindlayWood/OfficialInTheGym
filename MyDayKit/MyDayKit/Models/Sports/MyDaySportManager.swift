//
//  MyDaySportManager.swift
//  MyDayKit
//
//  Created by Findlay Wood on 05/11/2026.
//

import Foundation

/// Adds sport sessions to the selected day and takes them off again.
///
/// **A manager of its own rather than more of `MyDayManager`**, which already carries
/// exercises, clips, wellness, RPE and workouts. It owns no day state: the day is
/// `MyDayManager.selectedDay`, which every save on the MyDay screen goes through, so the
/// timeline and the date strip's markers update the moment a session is added. It writes
/// through one `MyDayAndSportSessionSaver` and never learns that there are two destinations.
///
/// **Today only.** Past days are read-only, and the day file saver names its file by the date
/// it saves on — a session added to a past day would be written into today's file over today.
/// The guard makes that an invariant rather than something the screen has to remember.
///
/// The day is updated before the write and is not rolled back if the write fails: the day file
/// is written first, and a failure there is as unrecoverable here as it is for every other save
/// in MyDay. A failure is logged, as the rest of the manager's saves are.
@MainActor
final class MyDaySportManager {

    // MARK: - Dependencies
    private let dayManager: MyDayManager
    private let saver: MyDayAndSportSessionSaver

    // MARK: - Init
    /// `nonisolated` so the coordinator, which is not main-actor isolated, can build it. It only
    /// stores its dependencies; everything that touches the day stays on the main actor.
    nonisolated init(dayManager: MyDayManager, saver: MyDayAndSportSessionSaver) {
        self.dayManager = dayManager
        self.saver = saver
    }

    /// The selected day's sessions, in the order they were added.
    var sessions: [SportSessionEntry] {
        dayManager.selectedDay?.sports ?? []
    }

    func add(_ session: SportSessionEntry) async {
        guard dayManager.isTodaySelected(), let selectedDay = dayManager.selectedDay else { return }
        let day = selectedDay.addingSport(session)
        dayManager.selectedDay = day
        do {
            try await saver.save(day: day, adding: session)
        } catch {
            print("❌ Error saving sport session \(session.id): \(error)")
        }
    }

    func remove(_ session: SportSessionEntry) async {
        guard dayManager.isTodaySelected(), let selectedDay = dayManager.selectedDay,
              selectedDay.sports?.contains(where: { $0.id == session.id }) == true else { return }
        let day = selectedDay.removingSport(id: session.id)
        dayManager.selectedDay = day
        do {
            try await saver.save(day: day, removing: session.id)
        } catch {
            print("❌ Error removing sport session \(session.id): \(error)")
        }
    }
}
