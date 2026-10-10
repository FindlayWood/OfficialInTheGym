//
//  RealtimeTrackedSessionsLoader.swift
//  InTheGym
//
//  Created by Findlay Wood on 10/10/2026.
//  Copyright © 2026 FindlayWood. All rights reserved.
//
import PerformanceKit

/// Reads the athlete's matches from `MatchTracking/{uid}` or practices from
/// `PracticeTracking/{uid}` in the Realtime Database, through the legacy
/// models and `FirebaseDatabaseManager`, which skips a record it cannot decode.
struct RealtimeTrackedSessionsLoader: TrackedSessionsLoader {

    let userId: String
    var apiService: FirebaseDatabaseManagerService = FirebaseDatabaseManager.shared

    func loadSessions(_ kind: TrackedSessionKind) async throws -> [TrackedSession] {
        switch kind {
        case .match:
            let records: [MatchTrackerModel] = try await apiService.fetchInstanceAsync(of: MatchTrackerSearchModel(id: userId))
            return records.map(TrackedSession.init(record:))
        case .practice:
            let records: [PracticeTrackerModel] = try await apiService.fetchInstanceAsync(of: PracticeTrackerSearchModel(id: userId))
            return records.map(TrackedSession.init(record:))
        }
    }
}
