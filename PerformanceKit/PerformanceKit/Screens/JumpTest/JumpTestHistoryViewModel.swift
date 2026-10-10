//
//  JumpTestHistoryViewModel.swift
//  PerformanceKit
//
//  Created by Findlay Wood on 10/10/2026.
//
import Combine
import Foundation

/// Every session of one jump test, newest first or highest first, shown in
/// centimetres or inches. A session's result is its best attempt's score:
/// height, or RSI for a drop jump. Vertical
/// jumps saved before the engine read as sessions of one attempt.
@MainActor
final class JumpTestHistoryViewModel: ObservableObject {

    let kind: JumpTestKind

    @Published private(set) var isLoading = false
    @Published private(set) var sessions: [JumpTestSession] = []
    @Published private(set) var sortedByDate = true
    @Published var measurement: JumpMeasurement = .cm

    private let loader: JumpTestSessionsLoader

    init(kind: JumpTestKind, loader: JumpTestSessionsLoader) {
        self.kind = kind
        self.loader = loader
    }

    var sortedSessions: [JumpTestSession] {
        sortedByDate
            ? sessions.sorted { $0.date > $1.date }
            : sessions.sorted { ($0.bestScore ?? 0) > ($1.bestScore ?? 0) }
    }

    func load() async {
        isLoading = true
        defer { isLoading = false }
        do {
            sessions = try await loader.loadSessions(kind)
        } catch {
            print("❌ \(kind.title) history load failed: \(error)")
        }
    }

    func sortByDate(_ value: Bool) {
        sortedByDate = value
    }
}
