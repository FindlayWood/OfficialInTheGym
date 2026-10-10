//
//  JumpTestHomeViewModel.swift
//  PerformanceKit
//
//  Created by Findlay Wood on 10/10/2026.
//
import Combine
import Foundation

/// A jump test's home: the athlete's best and latest results, and the way to
/// start a test, see every session, or read how it works. One screen for every
/// jump test, told apart by `kind`.
///
/// **The best is worked out from the sessions** (`JumpTestSession.best(of:)`),
/// never read from a document of its own. The legacy Vertical Jump screen read
/// `VerticalJump/{uid}`, a best kept beside the history by a second write, which
/// a failure between the two could leave disagreeing with it.
///
/// **Recording is offered only on your own Performance Center** (`canRecord`).
/// The legacy screens always showed the signed-in user's jumps, so a coach
/// opening an athlete's centre saw their own.
@MainActor
final class JumpTestHomeViewModel: ObservableObject {

    let kind: JumpTestKind

    @Published private(set) var isLoading = false
    @Published private(set) var sessions: [JumpTestSession] = []

    let canRecord: Bool

    var onStartTest: (() -> Void)?
    var onHistory: (() -> Void)?
    var onHelp: (() -> Void)?

    private let loader: JumpTestSessionsLoader

    init(kind: JumpTestKind, loader: JumpTestSessionsLoader, canRecord: Bool) {
        self.kind = kind
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
            sessions = try await loader.loadSessions(kind)
        } catch {
            print("❌ \(kind.title) load failed: \(error)")
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

    func history() {
        onHistory?()
    }

    func help() {
        onHelp?()
    }
}
