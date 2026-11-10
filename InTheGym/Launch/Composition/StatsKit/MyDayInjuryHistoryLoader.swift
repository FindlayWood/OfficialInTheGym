//
//  MyDayInjuryHistoryLoader.swift
//  InTheGym
//
//  Created by Findlay Wood on 10/11/2026.
//  Copyright © 2026 FindlayWood. All rights reserved.
//

import Foundation
import MyDayKit
import StatsKit

/// STATS' injuries, read from MyDay's store: the local files first, then Firestore, merged by
/// `Injury.merged` — **the one rule for reconciling the two**, so STATS and MyDay can never
/// disagree about what an injury holds.
///
/// **A remote failure is not an error once the phone has its own copy.** Injuries are rated on
/// this phone, so the local files are the freshest there is; Firestore only adds what another
/// device rated. Removed injuries (added by mistake) are left out — nothing reads them.
///
/// Reads the same two stores `InjuryManager` does but writes nothing: healing a stale remote
/// copy is MyDay's job, on its own load.
struct MyDayInjuryHistoryLoader: InjuryHistoryLoading {

    private let local: InjuryFetching
    private let remote: InjuryFetching

    init(userId: String) {
        self.local = FileManagerInjuryFetcher(userId: userId)
        self.remote = FirestoreInjuryFetcher(userId: userId)
    }

    func loadInjuries() async throws -> [StatsInjury] {
        let localInjuries = (try? await local.fetchAll()) ?? []
        let remoteInjuries: [Injury]
        do {
            remoteInjuries = try await remote.fetchAll()
        } catch {
            print("❌ Couldn't load remote injuries for STATS: \(error)")
            remoteInjuries = []
        }
        return Injury.merged(local: localInjuries, remote: remoteInjuries)
            .filter { $0.removedAt == nil }
            .map(Self.statsInjury(from:))
    }

    /// Impact maps by raw value — `StatsInjuryImpact` is StatsKit's copy of `InjuryImpact`.
    private static func statsInjury(from injury: Injury) -> StatsInjury {
        StatsInjury(
            id: injury.id,
            title: injury.title,
            startedOn: injury.startedOn.key,
            resolvedOn: injury.resolvedOn?.key,
            checkIns: injury.checkIns.compactMapValues { checkIn in
                StatsInjuryImpact(rawValue: checkIn.impact.rawValue).map {
                    StatsInjury.CheckIn(pain: checkIn.pain, impact: $0)
                }
            }
        )
    }
}
