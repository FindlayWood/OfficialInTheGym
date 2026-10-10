//
//  RealtimeWorkloadWriter.swift
//  InTheGym
//
//  Created by Findlay Wood on 10/10/2026.
//  Copyright © 2026 FindlayWood. All rights reserved.
//
import PerformanceKit

/// Adds an entry to `Workloads/{uid}` under a new time-ordered key.
///
/// **The path is the signed-in user's**, because `WorkloadModel` builds it from
/// `UserDefaults.currentUser` and this goes through that model so the entry is
/// stored as before. That is also the only log a session can be recorded into:
/// recording is offered on your own Performance Center only.
struct RealtimeWorkloadWriter: WorkloadWriter {

    var apiService: FirebaseDatabaseManagerService = FirebaseDatabaseManager.shared

    func write(_ workload: Workload) async throws {
        var record = WorkloadModel(workload)
        _ = try await apiService.uploadTimeOrderedModelAsync(data: &record)
    }
}
