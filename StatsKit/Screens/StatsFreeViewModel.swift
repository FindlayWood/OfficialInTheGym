//
//  StatsFreeViewModel.swift
//  StatsKit
//
//  Created by Findlay Wood on 27/10/2026.
//

import Combine
import Foundation

/// Loads the free STATS view: this week from the `DailyTotal`s, then the top lift.
///
/// **No reads the home does not already make.** It uses the router's own `DailyTotalsProviding`
/// and `ExerciseDailyStatsProviding`, and both collections are readable by their owner whether or
/// not they have pro — the gate is this screen, not the rules.
///
/// **The top lift loads after the week and fails on its own.** A failure there leaves the card
/// out rather than taking the week with it. Up to `topLiftAttempts` candidates are tried in
/// order, since `DailyTotal` cannot say which exercises carried weight — the most-logged one may
/// be planks.
@MainActor
final class StatsFreeViewModel: ObservableObject {

    enum State: Equatable {
        case loading
        case loaded
        case failed
    }

    @Published private(set) var state: State = .loading
    @Published private(set) var summary: StatsFreeSummary?
    @Published private(set) var topLift: StatsTopLift?

    var onShowPaywall: (() -> Void)?

    private let loader: DailyTotalsProviding
    private let exerciseDailyStatsLoader: ExerciseDailyStatsProviding

    static let topLiftAttempts = 3

    init(loader: DailyTotalsProviding, exerciseDailyStatsLoader: ExerciseDailyStatsProviding) {
        self.loader = loader
        self.exerciseDailyStatsLoader = exerciseDailyStatsLoader
    }

    func load() async {
        let asOf = Date.now
        do {
            let totals = try await loader.fetchDailyTotals()
            let summary = StatsFreeSummary(totals: totals, asOf: asOf)
            self.summary = summary
            state = .loaded
            topLift = await loadTopLift(candidates: summary.topLiftCandidates, asOf: asOf)
        } catch {
            print(String(describing: error))
            // A reload that fails keeps what the last one showed — stale beats blank.
            if summary == nil { state = .failed }
        }
    }

    func showPaywall() {
        onShowPaywall?()
    }

    private func loadTopLift(candidates: [String], asOf: Date) async -> StatsTopLift? {
        for exerciseID in candidates.prefix(Self.topLiftAttempts) {
            do {
                let stats = try await exerciseDailyStatsLoader.fetchDailyStats(
                    exerciseID: exerciseID,
                    from: StatsTopLift.fetchStart(asOf: asOf)
                )
                if let lift = StatsTopLift(exerciseID: exerciseID, stats: stats, asOf: asOf) {
                    return lift
                }
            } catch {
                print(String(describing: error))
                return nil
            }
        }
        return nil
    }
}
