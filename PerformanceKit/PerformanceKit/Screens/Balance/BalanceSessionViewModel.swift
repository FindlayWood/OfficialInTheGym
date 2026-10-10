//
//  BalanceSessionViewModel.swift
//  PerformanceKit
//
//  Created by Findlay Wood on 10/10/2026.
//
import Combine
import Foundation

/// One sitting of the balance test: pick eyes open or closed, then up to two
/// stands on each leg, handed over to the other leg once one is full, and
/// save once each leg has a stand.
///
/// **The condition is fixed once the first stand is in**, as the drop jump's
/// box is: stands under different conditions would not make one result. The
/// session id is fixed when the sitting starts, so a retried save overwrites.
@MainActor
final class BalanceSessionViewModel: ObservableObject {

    @Published var condition: BalanceCondition = .eyesOpen
    @Published var selectedSide: JumpSide = .left
    @Published private(set) var attempts: [BalanceAttempt] = []
    @Published private(set) var isSaving = false
    @Published private(set) var saveError: String?

    var onRecordStand: ((JumpSide) -> Void)?
    var onFinished: ((BalanceSession) -> Void)?
    var onCancel: (() -> Void)?

    private let writer: BalanceSessionWriter
    private let sessionId: String
    private let now: () -> Date

    init(writer: BalanceSessionWriter, now: @escaping () -> Date = Date.init, makeId: () -> String = { UUID().uuidString }) {
        self.writer = writer
        self.now = now
        self.sessionId = makeId()
    }

    func attempts(on side: JumpSide) -> [BalanceAttempt] {
        attempts.filter { $0.side == side }
    }

    var canRecordMore: Bool {
        attempts(on: selectedSide).count < BalanceSession.attemptsPerSide
    }

    var canSave: Bool {
        JumpSide.allCases.allSatisfy { !attempts(on: $0).isEmpty }
    }

    var symmetry: LimbSymmetry? {
        session.symmetry
    }

    /// The position in `attempts` of the steadiest complete stand on a leg.
    func bestIndex(on side: JumpSide) -> Int? {
        guard let best = session.best(on: side) else { return nil }
        return attempts.firstIndex(of: best)
    }

    func recordStand() {
        guard canRecordMore else { return }
        onRecordStand?(selectedSide)
    }

    func add(_ attempt: BalanceAttempt) {
        guard canRecordMore else { return }
        attempts.append(attempt.on(selectedSide))
        if !canRecordMore, let next = JumpSide.allCases.first(where: { attempts(on: $0).count < BalanceSession.attemptsPerSide }) {
            selectedSide = next
        }
    }

    func removeAttempt(at index: Int) {
        guard attempts.indices.contains(index) else { return }
        attempts.remove(at: index)
    }

    func cancel() {
        onCancel?()
    }

    func save() async {
        guard canSave else { return }
        isSaving = true
        saveError = nil
        defer { isSaving = false }
        do {
            try await writer.write(session)
            onFinished?(session)
        } catch {
            print("❌ Balance session save failed: \(error)")
            saveError = "Your stands couldn't be saved. Check your connection and try again."
        }
    }

    private var session: BalanceSession {
        BalanceSession(id: sessionId, date: now(), condition: condition, attempts: attempts)
    }
}
