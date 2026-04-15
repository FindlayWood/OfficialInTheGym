//
//  ExerciseStats.swift
//  StatsKit
//
//  Created by Findlay Wood on 22/03/2026.
//

import Foundation

// MARK: - Top-level exercise document (one per exercise)
public struct ExerciseStats: Identifiable, Hashable, Decodable {
    
    public var id: String {
        exerciseID
    }
    
    let exerciseID: String
    let exerciseName: String
    let userID: String

    // Totals (all-time, maintained at write time)
    let setCount: Int
    let totalReps: Int
    let totalWeight: Double
    let totalVolume: Double  // reps * weight per set, summed
    let totalTime: Int       // seconds, for timed exercises

    // Bests
    let maxWeight: Double
    let maxTime: Int

    // Dates
    let firstRecordDate: Date
    let lastRecordDate: Date
    let updatedAt: Date

    var isTimeBased: Bool { maxWeight == 0 && totalTime > 0 }
}

// MARK: - Mock data
extension ExerciseStats {
    static let mocks: [ExerciseStats] = [
        ExerciseStats(
            exerciseID: "ex1", exerciseName: "ATG Split Squat", userID: "user1",
            setCount: 18, totalReps: 216, totalWeight: 0, totalVolume: 0, totalTime: 0,
            maxWeight: 0, maxTime: 0,
            firstRecordDate: Calendar.current.date(byAdding: .day, value: -42, to: .now)!,
            lastRecordDate: Calendar.current.date(byAdding: .hour, value: -2, to: .now)!,
            updatedAt: .now
        ),
        ExerciseStats(
            exerciseID: "ex2", exerciseName: "Barbell Back Squat", userID: "user1",
            setCount: 32, totalReps: 256, totalWeight: 3200, totalVolume: 102400, totalTime: 0,
            maxWeight: 120, maxTime: 0,
            firstRecordDate: Calendar.current.date(byAdding: .day, value: -60, to: .now)!,
            lastRecordDate: Calendar.current.date(byAdding: .day, value: -1, to: .now)!,
            updatedAt: Calendar.current.date(byAdding: .day, value: -1, to: .now)!
        ),
        ExerciseStats(
            exerciseID: "ex3", exerciseName: "Romanian Deadlift", userID: "user1",
            setCount: 24, totalReps: 192, totalWeight: 1920, totalVolume: 61440, totalTime: 0,
            maxWeight: 90, maxTime: 0,
            firstRecordDate: Calendar.current.date(byAdding: .day, value: -55, to: .now)!,
            lastRecordDate: Calendar.current.date(byAdding: .day, value: -2, to: .now)!,
            updatedAt: Calendar.current.date(byAdding: .day, value: -2, to: .now)!
        ),
        ExerciseStats(
            exerciseID: "ex4", exerciseName: "Plank Hold", userID: "user1",
            setCount: 14, totalReps: 0, totalWeight: 0, totalVolume: 0, totalTime: 3360,
            maxWeight: 0, maxTime: 300,
            firstRecordDate: Calendar.current.date(byAdding: .day, value: -30, to: .now)!,
            lastRecordDate: Calendar.current.date(byAdding: .day, value: -3, to: .now)!,
            updatedAt: Calendar.current.date(byAdding: .day, value: -3, to: .now)!
        ),
        ExerciseStats(
            exerciseID: "ex5", exerciseName: "Nordic Curl", userID: "user1",
            setCount: 10, totalReps: 60, totalWeight: 0, totalVolume: 0, totalTime: 0,
            maxWeight: 0, maxTime: 0,
            firstRecordDate: Calendar.current.date(byAdding: .day, value: -20, to: .now)!,
            lastRecordDate: Calendar.current.date(byAdding: .day, value: -4, to: .now)!,
            updatedAt: Calendar.current.date(byAdding: .day, value: -4, to: .now)!
        ),
        ExerciseStats(
            exerciseID: "ex6", exerciseName: "Bulgarian Split Squat", userID: "user1",
            setCount: 20, totalReps: 240, totalWeight: 1200, totalVolume: 28800, totalTime: 0,
            maxWeight: 40, maxTime: 0,
            firstRecordDate: Calendar.current.date(byAdding: .day, value: -50, to: .now)!,
            lastRecordDate: Calendar.current.date(byAdding: .day, value: -5, to: .now)!,
            updatedAt: Calendar.current.date(byAdding: .day, value: -5, to: .now)!
        ),
    ]

    static func mockDates(daysAgo: [Int]) -> [String] {
        let fmt = DateFormatter()
        fmt.dateFormat = "yyyy-MM-dd"
        return daysAgo.map { fmt.string(from: Calendar.current.date(byAdding: .day, value: -$0, to: .now)!) }
    }
}
