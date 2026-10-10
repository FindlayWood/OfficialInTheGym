//
//  RealtimeTrackedSessionWriter.swift
//  InTheGym
//
//  Created by Findlay Wood on 10/10/2026.
//  Copyright © 2026 FindlayWood. All rights reserved.
//
import PerformanceKit

/// Adds a match to `MatchTracking/{uid}` or a practice to
/// `PracticeTracking/{uid}` under a new time-ordered key, through the legacy
/// model so it is stored exactly as before, and delivers it under that key.
struct RealtimeTrackedSessionWriter: TrackedSessionWriter {

    let userId: String
    var apiService: FirebaseDatabaseManagerService = FirebaseDatabaseManager.shared

    func write(_ session: TrackedSession, kind: TrackedSessionKind) async throws -> TrackedSession {
        switch kind {
        case .match:
            var record = MatchTrackerModel(
                id: session.id, userID: userId, date: session.date.timeIntervalSince1970,
                overallRating: session.ratings.overall, technicalRating: session.ratings.technical,
                tacticalRating: session.ratings.tactical, physicalRating: session.ratings.physical,
                mentalRating: session.ratings.mental, notes: session.notes,
                workloadRatio: session.workloadRatio.map(RatioModel.init),
                mostRecentWorkload: session.mostRecentWorkload.map(WorkloadModel.init),
                wellnessStatus: session.wellness.map(WellnessAnswersModel.init),
                cmjModel: session.cmj.map(CMJModel.init)
            )
            return TrackedSession(record: try await apiService.uploadTimeOrderedModelAsync(data: &record))
        case .practice:
            var record = PracticeTrackerModel(
                id: session.id, userID: userId, date: session.date.timeIntervalSince1970,
                overallRating: session.ratings.overall, technicalRating: session.ratings.technical,
                tacticalRating: session.ratings.tactical, physicalRating: session.ratings.physical,
                mentalRating: session.ratings.mental, notes: session.notes,
                workloadRatio: session.workloadRatio.map(RatioModel.init),
                mostRecentWorkload: session.mostRecentWorkload.map(WorkloadModel.init),
                wellnessStatus: session.wellness.map(WellnessAnswersModel.init),
                cmjModel: session.cmj.map(CMJModel.init)
            )
            return TrackedSession(record: try await apiService.uploadTimeOrderedModelAsync(data: &record))
        }
    }
}
