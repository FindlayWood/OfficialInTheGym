//
//  InjuryManager.swift
//  MyDayKit
//
//  Created by Findlay Wood on 10/11/2026.
//

import Combine
import Foundation

/// Holds the user's injuries, **local-first**, and is the one way to change them —
/// `ScheduleManager`'s shape.
///
/// `load()` shows the local files at once, then folds in the remote copy. A remote failure
/// changes nothing: an injury has to be rated with no signal, and offline means stale, not
/// broken.
///
/// **A load that finds the two copies disagreeing writes the merge back.** Firestore holds one
/// document per injury, replaced on every save, so a phone that rated Tuesday and an iPad that
/// rated Wednesday would each upload a copy missing the other's day. `Injury.merged` keeps both
/// on the device that reads them; writing that merge back is what puts both into Firestore.
///
/// **`updatedAt` is stamped here, in whole seconds**, on the injury and on each check-in, as
/// `ScheduleManager` does: local files store dates to the whole second, so a stamp with a
/// fraction would make the remote copy of one edit look newer than the local copy of the next.
public final class InjuryManager: ObservableObject {

    // MARK: - Properties
    /// Every injury, removed ones included, so that merging cannot bring one back. Screens read
    /// `active(on:)`.
    @Published public private(set) var injuries: [Injury] = []

    // MARK: - Dependencies
    private let saver: InjuryUploading
    private let local: InjuryFetching
    private let remote: InjuryFetching
    private let now: () -> Date
    private var isFetching = false
    private var hasLoadedRemote = false

    // MARK: - Init
    public init(
        saver: InjuryUploading,
        local: InjuryFetching,
        remote: InjuryFetching,
        now: @escaping () -> Date = Date.init
    ) {
        self.saver = saver
        self.local = local
        self.remote = remote
        self.now = now
    }
}

// MARK: - Loading
extension InjuryManager {

    /// Called on every appearance of a screen that reads injuries. Only a load that reached the
    /// remote copy counts as settled, so one made offline is tried again next time.
    @MainActor
    public func loadIfNeeded() async {
        guard !hasLoadedRemote else { return }
        await load()
    }

    @MainActor
    public func load() async {
        guard !isFetching else { return }
        isFetching = true
        defer { isFetching = false }

        let localInjuries = (try? await local.fetchAll()) ?? []
        injuries = Injury.merged(local: injuries, remote: localInjuries)

        let remoteInjuries: [Injury]
        do {
            remoteInjuries = try await remote.fetchAll()
            hasLoadedRemote = true
        } catch {
            print("❌ Couldn't load remote injuries: \(error)")
            return
        }
        injuries = Injury.merged(local: injuries, remote: remoteInjuries)

        // Write back whatever the remote copy is missing or holds differently. Local-only
        // injuries are included: the sync queue holds them too, and an upload is idempotent.
        let remoteById = Dictionary(remoteInjuries.map { ($0.id, $0) }, uniquingKeysWith: { first, _ in first })
        for injury in injuries where remoteById[injury.id] != injury {
            try? await saver.upload(injury)
        }
    }
}

// MARK: - Reading
extension InjuryManager {

    /// On MyDay on `day`, oldest first so the list does not reorder as new ones are added.
    public func active(on day: ScheduleDay) -> [Injury] {
        injuries
            .filter { $0.isActive(on: day) }
            .sorted { $0.startedOn != $1.startedOn ? $0.startedOn < $1.startedOn : $0.createdAt < $1.createdAt }
    }
}

// MARK: - Writing
extension InjuryManager {

    @MainActor
    @discardableResult
    public func add(region: InjuryRegion, side: InjurySide?, startedOn: ScheduleDay, note: String?) async throws -> Injury {
        let stamp = wholeSecondNow()
        let trimmed = note?.trimmingCharacters(in: .whitespacesAndNewlines)
        let injury = Injury(
            region: region,
            side: side,
            startedOn: startedOn,
            note: (trimmed?.isEmpty ?? true) ? nil : trimmed,
            createdAt: stamp,
            updatedAt: stamp
        )
        try await save(injury)
        return injury
    }

    /// Saves `day`'s check-in, replacing any earlier one that day.
    @MainActor
    public func checkIn(_ injury: Injury, pain: Int, impact: InjuryImpact, on day: ScheduleDay) async throws {
        var updated = current(injury)
        updated.checkIns[day.key] = InjuryCheckIn(pain: pain, impact: impact, updatedAt: wholeSecondNow())
        try await save(updated)
    }

    /// Cleared, from `day` on. It stops showing on MyDay that day.
    @MainActor
    public func resolve(_ injury: Injury, on day: ScheduleDay) async throws {
        var updated = current(injury)
        updated.resolvedOn = max(day, updated.startedOn)
        try await save(updated)
    }

    /// Added by mistake. Kept, marked, and read by nothing — see `Injury`.
    @MainActor
    public func remove(_ injury: Injury) async throws {
        var updated = current(injury)
        updated.removedAt = now()
        try await save(updated)
    }

    @MainActor
    private func save(_ injury: Injury) async throws {
        var stamped = injury
        stamped.updatedAt = wholeSecondNow()
        try await saver.upload(stamped)
        // Held copy first, so the stamped edit wins its own tie.
        injuries = Injury.merged(local: [stamped], remote: injuries)
    }

    /// The held copy of `injury`, so an edit made from a stale row value (a check-in on a row
    /// drawn before another check-in landed) does not drop what is already held.
    private func current(_ injury: Injury) -> Injury {
        injuries.first { $0.id == injury.id } ?? injury
    }

    private func wholeSecondNow() -> Date {
        Date(timeIntervalSince1970: now().timeIntervalSince1970.rounded(.down))
    }
}
