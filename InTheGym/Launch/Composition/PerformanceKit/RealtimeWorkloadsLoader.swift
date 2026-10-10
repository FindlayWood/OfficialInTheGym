//
//  RealtimeWorkloadsLoader.swift
//  InTheGym
//
//  Created by Findlay Wood on 10/10/2026.
//  Copyright © 2026 FindlayWood. All rights reserved.
//
import PerformanceKit

/// Reads the athlete's whole workload log from `Workloads/{uid}` in the
/// Realtime Database. A record that cannot be decoded is skipped, as
/// `FirebaseDatabaseManager` always has.
struct RealtimeWorkloadsLoader: WorkloadsLoader {

    let userId: String
    var apiService: FirebaseDatabaseManagerService = FirebaseDatabaseManager.shared

    func loadWorkloads() async throws -> [Workload] {
        let records: [WorkloadModel] = try await apiService.fetchInstanceAsync(of: WorkloadSearchModel(id: userId))
        return records.map(Workload.init(legacy:))
    }
}
