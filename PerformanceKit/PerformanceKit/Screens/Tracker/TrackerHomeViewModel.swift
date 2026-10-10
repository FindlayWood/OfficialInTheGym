//
//  TrackerHomeViewModel.swift
//  PerformanceKit
//
//  Created by Findlay Wood on 10/10/2026.
//
import Combine
import Foundation

/// Match Tracker or Practice Tracker's home: every recorded session, newest
/// first. The legacy `MatchTrackerViewModel` and `PracticeTrackerViewModel`
/// held this and the new-entry form together; the form is
/// `NewTrackedSessionViewModel` now.
///
/// **Recording is offered only on your own Performance Center** (`canRecord`),
/// as for Vertical Jump. The legacy trackers always read the signed-in user's
/// sessions, so a coach opening an athlete's centre saw their own.
///
/// **A session just recorded is added to the list at once.** The legacy screens
/// kept it in a property nothing read, so it appeared only after leaving and
/// coming back.
@MainActor
final class TrackerHomeViewModel: ObservableObject {

    let kind: TrackedSessionKind
    let canRecord: Bool

    @Published private(set) var sessions: [TrackedSession] = []
    @Published private(set) var isLoading = false
    @Published var isShowingNewEntry = false

    var onSelectSession: ((TrackedSession) -> Void)?

    private let loader: TrackedSessionsLoader

    init(kind: TrackedSessionKind, loader: TrackedSessionsLoader, canRecord: Bool = true) {
        self.kind = kind
        self.canRecord = canRecord
        self.loader = loader
    }

    func load() async {
        isLoading = true
        defer { isLoading = false }
        do {
            sessions = try await loader.loadSessions(kind).sorted { $0.date > $1.date }
        } catch {
            print("❌ \(kind.title) load failed: \(error)")
        }
    }

    func recordNew() {
        isShowingNewEntry = true
    }

    func sessionRecorded(_ session: TrackedSession) {
        sessions.insert(session, at: 0)
        isShowingNewEntry = false
    }

    func select(_ session: TrackedSession) {
        onSelectSession?(session)
    }
}
