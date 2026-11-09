//
//  MyDayFullDayModel+ReminderTestHelpers.swift
//  MyDayKitTests
//
//  Created by Findlay Wood on 09/11/2026.
//

import Foundation
@testable import MyDayKit

extension MyDayFullDayModel {

    /// A day with what the reminders read off it: a check-in, recorded training, a rating.
    static func reminderFixture(
        date: Date,
        checkedIn: Bool = false,
        trained: Bool = false,
        rated: Bool = false
    ) -> MyDayFullDayModel {
        MyDayFullDayModel(
            id: "day",
            date: date,
            exercises: [],
            workouts: [],
            rpeEntry: rated ? RPEEntry(date: date, score: 6) : nil,
            wellnessEntry: checkedIn
                ? WellnessEntry(date: date, sleepQuality: .four, physicalReadiness: .three, mentalEnergy: .four, overallMood: .four)
                : nil,
            sports: trained ? [.basketballGame(performedAt: date)] : nil
        )
    }
}
