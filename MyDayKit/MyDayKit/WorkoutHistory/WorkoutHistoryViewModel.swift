//
//  WorkoutHistoryViewModel.swift
//  MyDayKit
//
//  Created by Findlay Wood on 18/11/2026.
//

import Combine
import Foundation

/// The workout page's history card.
///
/// **Free**, by decision: how often you have done your own workout and how long it took is basic
/// history, not the analysis STATS sells.
///
/// **A failed read keeps whatever was shown**, and with nothing shown it is `.failed`, which the
/// card draws as a quiet line rather than an error. The card is a footnote to the workout, and a
/// network blip must not put a red banner on a page the user opened to train.
@MainActor
final class WorkoutHistoryViewModel: ObservableObject {

    enum State: Equatable {
        case loading
        case loaded(WorkoutHistorySummary)
        case failed
    }

    @Published private(set) var state: State = .loading

    let templateId: String
    private let loader: WorkoutHistoryLoader

    init(templateId: String, loader: WorkoutHistoryLoader) {
        self.templateId = templateId
        self.loader = loader
    }

    func load() async {
        do {
            let sessions = try await loader.sessions(forTemplate: templateId)
            state = .loaded(WorkoutHistorySummary(sessions: sessions))
        } catch {
            print("❌ Workout history failed: \(error)")
            if case .loaded = state { return }
            state = .failed
        }
    }
}
