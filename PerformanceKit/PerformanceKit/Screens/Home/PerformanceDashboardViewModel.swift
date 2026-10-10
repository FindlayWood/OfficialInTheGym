//
//  PerformanceDashboardViewModel.swift
//  PerformanceKit
//
//  Created by Findlay Wood on 10/10/2026.
//
import Combine
import Foundation

/// The PERFORMANCE home: the weekly fatigue check first, then the key numbers,
/// then the tests. It answers "am I fresh?" before it lists anything.
///
/// It reads CMJ and Vertical Jump sessions **separately, and each fails on its
/// own**, so a Vertical Jump read that fails does not hide this week's check.
/// It reloads every time the tab appears, which is also how a test saved from
/// a test's own screen reaches it.
@MainActor
final class PerformanceDashboardViewModel: ObservableObject {

    let tools = PerformanceTool.allCases
    let canRecord: Bool

    @Published private(set) var cmjSessions: [JumpTestSession] = []
    @Published private(set) var verticalJumpSessions: [JumpTestSession] = []
    @Published private(set) var isLoading = false
    @Published private(set) var hasLoaded = false

    var onSelectTool: ((PerformanceTool) -> Void)?
    var onStartCheck: (() -> Void)?

    private let loader: JumpTestSessionsLoader
    private let now: () -> Date
    private let calendar: Calendar

    init(loader: JumpTestSessionsLoader, canRecord: Bool, now: @escaping () -> Date = Date.init, calendar: Calendar = .current) {
        self.loader = loader
        self.canRecord = canRecord
        self.now = now
        self.calendar = calendar
    }

    var check: FatigueCheck {
        FatigueCheck(sessions: cmjSessions, calendar: calendar)
    }

    var isCheckDue: Bool {
        check.isDue(now: now())
    }

    var bestCMJ: JumpTestSession? {
        JumpTestSession.best(of: cmjSessions)
    }

    var bestVerticalJump: JumpTestSession? {
        JumpTestSession.best(of: verticalJumpSessions)
    }

    /// The power of the best CMJ that has one, so a best jumped before a
    /// weight was logged does not leave the tile empty when a later one has it.
    var bestPower: JumpPower? {
        cmjSessions
            .compactMap(\.power)
            .max { $0.wattsPerKilogram < $1.wattsPerKilogram }
    }

    func load() async {
        isLoading = true
        defer {
            isLoading = false
            hasLoaded = true
        }
        async let cmj = sessions(.cmj)
        async let verticalJump = sessions(.verticalJump)
        if let cmj = await cmj { cmjSessions = cmj }
        if let verticalJump = await verticalJump { verticalJumpSessions = verticalJump }
    }

    /// A session just saved counts at once, without a reload.
    func sessionSaved(_ session: JumpTestSession) {
        switch session.kind {
        case .cmj:
            cmjSessions.removeAll { $0.id == session.id }
            cmjSessions.append(session)
        case .verticalJump:
            verticalJumpSessions.removeAll { $0.id == session.id }
            verticalJumpSessions.append(session)
        }
    }

    func select(_ tool: PerformanceTool) {
        onSelectTool?(tool)
    }

    func startCheck() {
        onStartCheck?()
    }

    private func sessions(_ kind: JumpTestKind) async -> [JumpTestSession]? {
        do {
            return try await loader.loadSessions(kind)
        } catch {
            print("❌ Dashboard \(kind.title) load failed: \(error)")
            return nil
        }
    }
}
