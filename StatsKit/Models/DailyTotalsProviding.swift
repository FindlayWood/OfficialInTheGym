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

    // Generates 120 days of mock data with activity on ~70% of days — the same
    // window the real loader fetches, so previews exercise the full chronic
    // window rather than the short one that hid the ACWR's edges.
    private static func generated() -> [DailyTotal] {
        // Every third active day is exercise-only: a DailyTotal with volume and
        // no workload, which is the case the two separate ACWRs exist for.
        (0..<120)
            .filter { $0 % 10 != 2 && $0 % 10 != 6 && $0 % 10 != 9 }
            .map { offset in
                let date = StatsDay.date(daysAgo: offset)
                return DailyTotal(
                    id: StatsDay.key(for: date),
                    date: date,
                    userID: "mockUser",
                    totalSets: Int.random(in: 6...15),
                    totalReps: Int.random(in: 40...120),
                    totalWeight: Double(Int.random(in: 200...600)),
                    totalVolume: Double(Int.random(in: 2000...8000)),
                    totalTime: Int.random(in: 0...300),
                    exerciseSetCounts: [:],
                    totalWorkload: offset % 3 == 0
                        ? nil
                        : Double(Int.random(in: 200...600))
                )
            }
    }
}
