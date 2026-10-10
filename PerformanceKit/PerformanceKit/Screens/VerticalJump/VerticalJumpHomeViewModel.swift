//
//  VerticalJumpHomeViewModel.swift
//  PerformanceKit
//
//  Created by Findlay Wood on 10/10/2026.
//
import Combine
import Foundation

/// Vertical Jump's home: the athlete's best and latest results, and the way to
/// start a test, see every session, or read how it works.
///
/// **The best is worked out from the sessions** (`JumpTestSession.best(of:)`),
/// never read from a document of its own. The legacy screen read
/// `VerticalJump/{uid}`, a best kept beside the history by a second write, which
/// a failure between the two could leave disagreeing with it.
///
/// **Recording is offered only on your own Performance Center** (`canRecord`).
/// The legacy screens always showed the signed-in user's jumps, so a coach
/// opening an athlete's centre saw their own.
@MainActor
final class VerticalJumpHomeViewModel: ObservableObject {

    @Published private(set) var isLoading = false
    @Published private(set) var sessions: [JumpTestSession] = []

    let canRecord: Bool

    var onStartTest: (() -> Void)?
    var onPreviousJumps: (() -> Void)?
    var onHelp: (() -> Void)?

    private let loader: JumpTestSessionsLoader

    init(loader: JumpTestSessionsLoader, canRecord: Bool) {
        self.loader = loader
        self.canRecord = canRecord
    }

    var best: JumpTestSession? {
        JumpTestSession.best(of: sessions)
    }

    var latest: JumpTestSession? {
        sessions.max { $0.date < $1.date }
    }

    func load() async {
        isLoading = true
        defer { isLoading = false }
        do {
            sessions = try await loader.loadSessions(.verticalJump)
        } catch {
            print("❌ Vertical jump load failed: \(error)")
        }
    }

    /// A session just saved counts at once, without a reload.
    func sessionSaved(_ session: JumpTestSession) {
        sessions.removeAll { $0.id == session.id }
        sessions.append(session)
    }

    func startTest() {
        onStartTest?()
    }

    func previousJumps() {
        onPreviousJumps?()
    }

    func help() {
        onHelp?()
    }
}
