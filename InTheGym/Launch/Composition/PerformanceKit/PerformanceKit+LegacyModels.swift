//
//  PerformanceKit+LegacyModels.swift
//  InTheGym
//
//  Created by Findlay Wood on 10/10/2026.
//  Copyright © 2026 FindlayWood. All rights reserved.
//
import Foundation
import PerformanceKit

// PerformanceKit's models to and from the app target's legacy ones, which still
// do the encoding, so records keep the shape they have always been stored in.
// Every field goes both ways.

extension Workload {
    init(legacy model: WorkloadModel) {
        self.init(
            id: model.id,
            endTime: Date(timeIntervalSince1970: model.endTime),
            rpe: model.rpe,
            timeToComplete: model.timeToComplete,
            workload: model.workload,
            customAddedWorkload: model.customAddedWorkload,
            matchWorkload: model.matchWorkload,
            practiceWorkload: model.practiceWorkload,
            workoutID: model.workoutID
        )
    }
}

extension WorkloadModel {
    init(_ workload: Workload) {
        self.init(
            id: workload.id,
            endTime: workload.endTime.timeIntervalSince1970,
            rpe: workload.rpe,
            timeToComplete: workload.timeToComplete,
            workload: workload.workload,
            customAddedWorkload: workload.customAddedWorkload,
            matchWorkload: workload.matchWorkload,
            practiceWorkload: workload.practiceWorkload,
            workoutID: workload.workoutID
        )
    }
}

extension WorkloadRatio {
    init(legacy model: RatioModel) {
        self.init(
            acwr: model.acwr,
            monotony: model.monotony,
            trainingStrain: model.trainingStrain,
            acuteLoad: model.acuteLoad,
            chronicLoad: model.chronicLoad,
            freshnessIndex: model.freshnessIndex
        )
    }
}

extension RatioModel {
    init(_ ratio: WorkloadRatio) {
        self.init(
            acwr: ratio.acwr,
            monotony: ratio.monotony,
            trainingStrain: ratio.trainingStrain,
            acuteLoad: ratio.acuteLoad,
            chronicLoad: ratio.chronicLoad,
            freshnessIndex: ratio.freshnessIndex
        )
    }
}

extension WellnessSnapshot {
    init(legacy model: WellnessAnswersModel) {
        self.init(
            time: model.time,
            sleepAmount: model.sleepAmount,
            sleepQuality: model.sleepQuality,
            bodyFeeling: model.bodyFeeling,
            mindFeeling: model.mindFeeling,
            happyFeeling: model.happyFeeling,
            motivationFeeling: model.motivationFeeling,
            status: model.status.rawValue,
            statusTitle: model.status.title
        )
    }
}

extension WellnessAnswersModel {
    init(_ snapshot: WellnessSnapshot) {
        self.init(
            time: snapshot.time,
            sleepAmount: snapshot.sleepAmount,
            sleepQuality: snapshot.sleepQuality,
            bodyFeeling: snapshot.bodyFeeling,
            mindFeeling: snapshot.mindFeeling,
            happyFeeling: snapshot.happyFeeling,
            motivationFeeling: snapshot.motivationFeeling,
            status: WellnessStatus(rawValue: snapshot.status) ?? .na
        )
    }
}

extension CMJSnapshot {
    init(legacy model: CMJModel) {
        self.init(
            mostRecentData: model.mostRecentData,
            jumpNumber: model.jumpNumber,
            peakPower: model.peakPower,
            averagePower: model.averagePower,
            fatigueLevel: model.fatigueLevel.rawValue,
            fatigueLevelTitle: model.fatigueLevel.title,
            maxHeight: model.maxHeight,
            maxDate: model.maxDate
        )
    }
}

extension CMJModel {
    init(_ snapshot: CMJSnapshot) {
        self.init(
            mostRecentData: snapshot.mostRecentData,
            jumpNumber: snapshot.jumpNumber,
            peakPower: snapshot.peakPower,
            averagePower: snapshot.averagePower,
            fatigueLevel: CMJFatigueLevel(rawValue: snapshot.fatigueLevel) ?? .na,
            maxHeight: snapshot.maxHeight,
            maxDate: snapshot.maxDate
        )
    }
}
