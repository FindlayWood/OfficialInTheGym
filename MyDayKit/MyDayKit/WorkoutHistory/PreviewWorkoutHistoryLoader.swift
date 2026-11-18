//
//  PreviewWorkoutHistoryLoader.swift
//  MyDayKit
//
//  Created by Findlay Wood on 18/11/2026.
//

import Foundation

/// Preview conformer: four sessions of the workout over the last month, one with no RPE, so the
/// card shows an average that leaves a gap out rather than counting it as zero.
public final class PreviewWorkoutHistoryLoader: WorkoutHistoryLoader, @unchecked Sendable {

    public init() {}

    public func sessions(forTemplate templateId: String) async throws -> [CompletedWorkoutSession] {
        let durations = [2_700, 3_000, 2_880, 3_120]
        let rpes: [Int?] = [7, 8, nil, 7]
        return durations.indices.map { index in
            let startedAt = Date.now.addingTimeInterval(-Double(index * 7 + 2) * 86_400)
            return CompletedWorkoutSession(
                id: "preview-\(index)",
                userId: "preview",
                templateId: templateId,
                title: "Preview",
                assignedDate: startedAt,
                startedAt: startedAt,
                endedAt: startedAt.addingTimeInterval(Double(durations[index])),
                durationSeconds: durations[index],
                rpe: rpes[index],
                setsCompleted: 12,
                setsTargeted: 12,
                exerciseRecords: []
            )
        }
    }
}
