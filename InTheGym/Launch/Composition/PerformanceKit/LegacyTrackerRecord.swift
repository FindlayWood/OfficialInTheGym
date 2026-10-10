//
//  LegacyTrackerRecord.swift
//  InTheGym
//
//  Created by Findlay Wood on 10/10/2026.
//  Copyright © 2026 FindlayWood. All rights reserved.
//
import Foundation
import PerformanceKit

/// What `MatchTrackerModel` and `PracticeTrackerModel` have in common, which is
/// everything but their path. They stay two types because each knows its own
/// Realtime Database path (`MatchTracking/{uid}`, `PracticeTracking/{uid}`) and
/// their encoding is the stored shape. This lets one mapping read both.
protocol LegacyTrackerRecord {
    var id: String { get }
    var date: TimeInterval { get }
    var overallRating: Int { get }
    var technicalRating: Int { get }
    var tacticalRating: Int { get }
    var physicalRating: Int { get }
    var mentalRating: Int { get }
    var notes: String { get }
    var workloadRatio: RatioModel? { get }
    var mostRecentWorkload: WorkloadModel? { get }
    var wellnessStatus: WellnessAnswersModel? { get }
    var cmjModel: CMJModel? { get }
}

extension MatchTrackerModel: LegacyTrackerRecord {}
extension PracticeTrackerModel: LegacyTrackerRecord {}

extension TrackedSession {

    init(record: LegacyTrackerRecord) {
        self.init(
            id: record.id,
            date: Date(timeIntervalSince1970: record.date),
            ratings: TrackedSessionRatings(
                overall: record.overallRating,
                technical: record.technicalRating,
                tactical: record.tacticalRating,
                physical: record.physicalRating,
                mental: record.mentalRating
            ),
            notes: record.notes,
            workloadRatio: record.workloadRatio.map(WorkloadRatio.init(legacy:)),
            mostRecentWorkload: record.mostRecentWorkload.map(Workload.init(legacy:)),
            wellness: record.wellnessStatus.map(WellnessSnapshot.init(legacy:)),
            cmj: record.cmjModel.map(CMJSnapshot.init(legacy:))
        )
    }
}
