//
//  StatsModels.swift
//  StatsKit
//
//  Created by Findlay Wood on 19/03/2026.
//

import Foundation

// MARK: - Top-level exercise document (one per exercise)
public struct ExerciseSummary: Identifiable, Hashable, Decodable {
    public let id: String
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

    // Array of calendar days (yyyy-MM-dd strings) that had at least one set.
    // Maintain this at write time — last 30 days only to keep it small.
    let recentActiveDates: [String]

    var isTimeBased: Bool { maxWeight == 0 && totalTime > 0 }
}

// MARK: - Individual set document (sub-collection under each exercise)
struct ExerciseSet: Identifiable, Hashable {
    let id: String
    let exerciseID: String
    let exerciseName: String
    let reps: Int
    let weight: Double
    let time: Int       // seconds; 0 for rep-based exercises
    let dateComplete: Date

    var volume: Double { Double(reps) * weight }

    var formattedTime: String {
        guard time > 0 else { return "" }
        let m = time / 60
        let s = time % 60
        return String(format: "%d:%02d", m, s)
    }
}

// MARK: - Grouped sets for graphing
struct DailyAggregate: Identifiable {
    let id: String  // yyyy-MM-dd
    let date: Date
    let totalReps: Int
    let totalVolume: Double
    let totalTime: Int
    let setCount: Int
}

// MARK: - Graph range option
enum StatRange: String, CaseIterable, Identifiable {
    case week   = "1W"
    case twoWeeks = "2W"
    case month  = "1M"
    case allTime = "All"
    var id: String { rawValue }
}

// MARK: - Mock data
extension ExerciseSummary {
    static let mocks: [ExerciseSummary] = [
        ExerciseSummary(
            id: "1", exerciseID: "ex1", exerciseName: "ATG Split Squat", userID: "user1",
            setCount: 18, totalReps: 216, totalWeight: 0, totalVolume: 0, totalTime: 0,
            maxWeight: 0, maxTime: 0,
            firstRecordDate: Calendar.current.date(byAdding: .day, value: -42, to: .now)!,
            lastRecordDate: Calendar.current.date(byAdding: .hour, value: -2, to: .now)!,
            updatedAt: .now,
            recentActiveDates: ExerciseSummary.mockDates(daysAgo: [0, 1, 3, 5, 7, 9, 12, 14])
        ),
        ExerciseSummary(
            id: "2", exerciseID: "ex2", exerciseName: "Barbell Back Squat", userID: "user1",
            setCount: 32, totalReps: 256, totalWeight: 3200, totalVolume: 102400, totalTime: 0,
            maxWeight: 120, maxTime: 0,
            firstRecordDate: Calendar.current.date(byAdding: .day, value: -60, to: .now)!,
            lastRecordDate: Calendar.current.date(byAdding: .day, value: -1, to: .now)!,
            updatedAt: Calendar.current.date(byAdding: .day, value: -1, to: .now)!,
            recentActiveDates: ExerciseSummary.mockDates(daysAgo: [1, 4, 8, 11, 15, 18])
        ),
        ExerciseSummary(
            id: "3", exerciseID: "ex3", exerciseName: "Romanian Deadlift", userID: "user1",
            setCount: 24, totalReps: 192, totalWeight: 1920, totalVolume: 61440, totalTime: 0,
            maxWeight: 90, maxTime: 0,
            firstRecordDate: Calendar.current.date(byAdding: .day, value: -55, to: .now)!,
            lastRecordDate: Calendar.current.date(byAdding: .day, value: -2, to: .now)!,
            updatedAt: Calendar.current.date(byAdding: .day, value: -2, to: .now)!,
            recentActiveDates: ExerciseSummary.mockDates(daysAgo: [2, 6, 9, 13, 16, 20])
        ),
        ExerciseSummary(
            id: "4", exerciseID: "ex4", exerciseName: "Plank Hold", userID: "user1",
            setCount: 14, totalReps: 0, totalWeight: 0, totalVolume: 0, totalTime: 3360,
            maxWeight: 0, maxTime: 300,
            firstRecordDate: Calendar.current.date(byAdding: .day, value: -30, to: .now)!,
            lastRecordDate: Calendar.current.date(byAdding: .day, value: -3, to: .now)!,
            updatedAt: Calendar.current.date(byAdding: .day, value: -3, to: .now)!,
            recentActiveDates: ExerciseSummary.mockDates(daysAgo: [3, 7, 10, 14, 17])
        ),
        ExerciseSummary(
            id: "5", exerciseID: "ex5", exerciseName: "Nordic Curl", userID: "user1",
            setCount: 10, totalReps: 60, totalWeight: 0, totalVolume: 0, totalTime: 0,
            maxWeight: 0, maxTime: 0,
            firstRecordDate: Calendar.current.date(byAdding: .day, value: -20, to: .now)!,
            lastRecordDate: Calendar.current.date(byAdding: .day, value: -4, to: .now)!,
            updatedAt: Calendar.current.date(byAdding: .day, value: -4, to: .now)!,
            recentActiveDates: ExerciseSummary.mockDates(daysAgo: [4, 8, 12, 16, 20])
        ),
        ExerciseSummary(
            id: "6", exerciseID: "ex6", exerciseName: "Bulgarian Split Squat", userID: "user1",
            setCount: 20, totalReps: 240, totalWeight: 1200, totalVolume: 28800, totalTime: 0,
            maxWeight: 40, maxTime: 0,
            firstRecordDate: Calendar.current.date(byAdding: .day, value: -50, to: .now)!,
            lastRecordDate: Calendar.current.date(byAdding: .day, value: -5, to: .now)!,
            updatedAt: Calendar.current.date(byAdding: .day, value: -5, to: .now)!,
            recentActiveDates: ExerciseSummary.mockDates(daysAgo: [5, 9, 13, 17, 21])
        ),
    ]

    static func mockDates(daysAgo: [Int]) -> [String] {
        let fmt = DateFormatter()
        fmt.dateFormat = "yyyy-MM-dd"
        return daysAgo.map { fmt.string(from: Calendar.current.date(byAdding: .day, value: -$0, to: .now)!) }
    }
}

extension ExerciseSet {
    static func mocks(for exerciseID: String) -> [ExerciseSet] {
        let weights: [Double] = [0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0]
        let reps = [10, 12, 11, 12, 13, 12, 14, 13, 15, 14, 12, 14, 15, 16, 14, 15, 16, 12]
        return (0..<18).map { i in
            ExerciseSet(
                id: "\(exerciseID)-set-\(i)",
                exerciseID: exerciseID,
                exerciseName: "ATG Split Squat",
                reps: reps[i],
                weight: weights[i],
                time: 0,
                dateComplete: Calendar.current.date(byAdding: .day, value: -(17 - i) * 2, to: .now)!
            )
        }
    }
}
