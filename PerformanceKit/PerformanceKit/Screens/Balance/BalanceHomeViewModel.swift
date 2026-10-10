//
//  BalanceHomeViewModel.swift
//  PerformanceKit
//
//  Created by Findlay Wood on 10/10/2026.
//
import Combine
import Foundation

/// Balance's home: the latest result, and the way to start a test, see every
/// session, or read how it works. **The latest, not a best**: sway is a
/// reading of how the athlete is standing now, and a best from months ago says
/// little about that. Recording is offered only on your own centre.
@MainActor
final class BalanceHomeViewModel: ObservableObject {

    @Published private(set) var isLoading = false
    @Published private(set) var sessions: [BalanceSession] = []

    let canRecord: Bool

    var onStartTest: (() -> Void)?
    var onHistory: (() -> Void)?
    var onHelp: (() -> Void)?

    private let loader: BalanceSessionsLoader

    init(loader: BalanceSessionsLoader, canRecord: Bool) {
        self.loader = loader
        self.canRecord = canRecord
    }

    var latest: BalanceSession? {
        sessions.max { $0.date < $1.date }
    }

    func load() async {
        isLoading = true
        defer { isLoading = false }
        do {
            sessions = try await loader.loadBalanceSessions()
        } catch {
            print("❌ Balance load failed: \(error)")
        }
    }

    func sessionSaved(_ session: BalanceSession) {
        sessions.removeAll { $0.id == session.id }
        sessions.append(session)
    }

    func startTest() { onStartTest?() }
    func history() { onHistory?() }
    func help() { onHelp?() }
}
