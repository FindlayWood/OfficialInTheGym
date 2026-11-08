//
//  ScheduleManager.swift
//  MyDayKit
//
//  Created by Findlay Wood on 08/11/2026.
//

import Combine
import Foundation

/// Holds the user's schedules, **local-first**, and is the one way to change them.
///
/// `load()` shows the local files at once, then folds in the remote copy. A remote failure changes
/// nothing: MyDay has to work offline, and being offline means the list is stale, not broken. There
/// is no failed state to draw, because a schedule that cannot be read yet only means a card that
/// has not appeared yet.
///
/// **Only the local write can fail a save**, which `ScheduleUploading`'s composed saver decides, so
/// a schedule made with no signal is on MyDay at once.
///
/// **`updatedAt` is stamped here, in whole seconds.** It decides which copy wins a merge, so no
/// caller should have to remember it. Local files store dates to the whole second, so a stamp with
/// a fraction would make the remote copy of an edit look newer than the local copy of the next one.
public final class ScheduleManager: ObservableObject {

    /// Every schedule, stopped ones included, so that merging cannot bring one back. Screens read
    /// `due(on:)` or `active(on:)`.
    @Published public private(set) var schedules: [Schedule] = []

    private let saver: ScheduleUploading
    private let local: ScheduleFetching
    private let remote: ScheduleFetching
    private let now: () -> Date
    private var isFetching = false

    // MARK: - Init

    public init(
        saver: ScheduleUploading,
        local: ScheduleFetching,
        remote: ScheduleFetching,
        now: @escaping () -> Date = Date.init
    ) {
        self.saver = saver
        self.local = local
        self.remote = remote
        self.now = now
    }

    // MARK: - Loading

    /// Merged with what is already held at each stage rather than replacing it, so a schedule saved
    /// while this is running is not lost when it settles.
    @MainActor
    public func load() async {
        guard !isFetching else { return }
        isFetching = true
        defer { isFetching = false }

        let localSchedules = (try? await local.fetchAll()) ?? []
        schedules = Schedule.merged(local: schedules, remote: localSchedules)

        do {
            let remoteSchedules = try await remote.fetchAll()
            schedules = Schedule.merged(local: schedules, remote: remoteSchedules)
        } catch {
            print("❌ Couldn't load remote schedules: \(error)")
        }
    }

    // MARK: - Reading

    /// What is due on `day`, for MyDay's cards.
    public func due(on day: ScheduleDay) -> [Schedule] {
        schedules.filter { $0.isDue(on: day) }
    }

    /// What is still to come from `day` on, for the Scheduled list. A stopped schedule and a
    /// finished one-off are both left out.
    public func active(on day: ScheduleDay) -> [Schedule] {
        schedules.filter { $0.nextDue(onOrAfter: day) != nil }
    }

    // MARK: - Writing

    @MainActor
    public func save(_ schedule: Schedule) async throws {
        var stamped = schedule
        stamped.updatedAt = wholeSecondNow()
        try await saver.upload(stamped)

        schedules = Schedule.merged(local: [stamped], remote: schedules)
    }

    /// Stops `schedule` from today on. Anything already logged from it stays on its day.
    @MainActor
    public func stop(_ schedule: Schedule) async throws {
        var stopped = schedule
        stopped.stoppedAt = now()
        try await save(stopped)
    }

    private func wholeSecondNow() -> Date {
        Date(timeIntervalSince1970: now().timeIntervalSince1970.rounded(.down))
    }
}
