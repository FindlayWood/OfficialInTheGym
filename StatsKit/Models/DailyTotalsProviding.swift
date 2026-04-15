//
//  DailyTotalsProviding.swift
//  StatsKit
//
//  Created by Findlay Wood on 21/03/2026.
//

import Foundation

// MARK: - DailyTotalsProviding
// Implement this protocol in the composition root (e.g. using FirebaseFirestore)
// and inject it into the ViewModel. The implementation is responsible for
// determining the userID and date range to load.
public protocol DailyTotalsProviding {
    /// Fetches DailyTotal documents for the current user.
    /// - Returns: An array of DailyTotal sorted ascending by date.
    func fetchDailyTotals() async throws -> [DailyTotal]
}

// MARK: - Mock implementation (for previews and testing)
public final class MockDailyTotalsProvider: DailyTotalsProviding, @unchecked Sendable {
    private let totals: [DailyTotal]

    /// Initialise with specific totals, or leave empty to use generated mock data.
    public init(totals: [DailyTotal]? = nil) {
        self.totals = totals ?? MockDailyTotalsProvider.generated()
    }

    public func fetchDailyTotals() async throws -> [DailyTotal] {
        totals
    }

    /// Synchronous access for SwiftUI previews
    public var previewTotals: [DailyTotal] { totals }

    // Generates 30 days of mock data with activity on ~70% of days
    private static func generated() -> [DailyTotal] {
        let activeDayOffsets = [0, 1, 3, 4, 5, 7, 8, 10, 12, 14,
                                15, 17, 19, 21, 22, 24, 25, 26, 28, 29]
        return activeDayOffsets.map { offset in
            let date = Calendar.current.date(byAdding: .day, value: -offset, to: .now)!
            let key = DateFormatter.yyyyMMdd.string(from: date)
            return DailyTotal(
                id: key,
                date: date,
                userID: "mockUser",
                totalSets: Int.random(in: 6...15),
                totalReps: Int.random(in: 40...120),
                totalWeight: Double(Int.random(in: 200...600)),
                totalVolume: Double(Int.random(in: 2000...8000)),
                totalTime: Int.random(in: 0...300),
                exerciseSetCounts: [:]
            )
        }
    }
}
