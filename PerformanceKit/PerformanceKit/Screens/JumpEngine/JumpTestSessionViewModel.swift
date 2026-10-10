//
//  JumpTestSessionViewModel.swift
//  PerformanceKit
//
//  Created by Findlay Wood on 10/10/2026.
//
import Combine
import Foundation

/// One sitting of a jump test: record up to `kind.attempts` jumps, see each
/// one's height with the best marked, and save the session.
///
/// **The session id is fixed when the sitting starts**, not when it is saved,
/// so a save that fails and is tried again overwrites the same document rather
/// than adding a second session.
///
/// **Body mass is read when the sitting opens** (`loadBodyMass()`) and saved
/// with the session, for a test that estimates power. A failed or empty read is
/// no mass: the jumps still save, without power.
///
/// The session can be saved after any number of attempts from one up. Three
/// is what the screen asks for, and the cap. An attempt can be removed and
/// re-recorded, for a jump that went wrong or was tagged badly.
@MainActor
final class JumpTestSessionViewModel: ObservableObject {

    let kind: JumpTestKind

    @Published private(set) var attempts: [JumpAttempt] = []
    @Published var measurement: JumpMeasurement = .cm
    @Published private(set) var isSaving = false
    @Published private(set) var saveError: String?
    @Published private(set) var bodyMass: Double?
    /// The box a drop jump is done off, in centimetres, for a test that uses
    /// one. Chosen before the first attempt; RSI is only comparable off the
    /// same box.
    @Published var boxHeight: Double = 30

    static let boxHeights: [Double] = [20, 30, 40, 50, 60]

    var onRecordAttempt: (() -> Void)?
    var onFinished: ((JumpTestSession) -> Void)?
    var onCancel: (() -> Void)?

    private let writer: JumpTestSessionWriter
    private let bodyMassLoader: BodyMassLoader
    private let sessionId: String
    private let now: () -> Date

    init(kind: JumpTestKind, writer: JumpTestSessionWriter, bodyMassLoader: BodyMassLoader, now: @escaping () -> Date = Date.init, makeId: () -> String = { UUID().uuidString }) {
        self.kind = kind
        self.writer = writer
        self.bodyMassLoader = bodyMassLoader
        self.now = now
        self.sessionId = makeId()
    }

    var canRecordMore: Bool {
        attempts.count < kind.attempts
    }

    var canSave: Bool {
        !attempts.isEmpty
    }

    /// The position of the best attempt by the test's score (height, or RSI).
    /// The first of equal scores, so the marker does not jump to a later
    /// attempt that only matched it.
    var bestIndex: Int? {
        guard let best = attempts.map({ $0.score(for: kind) }).max() else { return nil }
        return attempts.firstIndex { $0.score(for: kind) == best }
    }

    /// The best attempt's power so far, for a test that estimates it.
    var bestPower: JumpPower? {
        session.power
    }

    func loadBodyMass() async {
        guard kind.estimatesPower, bodyMass == nil else { return }
        do {
            bodyMass = try await bodyMassLoader.loadBodyMass()
        } catch {
            print("❌ Body mass load failed: \(error)")
        }
    }

    func recordAttempt() {
        guard canRecordMore else { return }
        onRecordAttempt?()
    }

    func add(_ attempt: JumpAttempt) {
        guard canRecordMore else { return }
        attempts.append(attempt)
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
        let session = self.session
        do {
            try await writer.write(session)
            onFinished?(session)
        } catch {
            print("❌ \(kind.title) session save failed: \(error)")
            saveError = "Your jumps couldn't be saved. Check your connection and try again."
        }
    }

    private var session: JumpTestSession {
        JumpTestSession(
            id: sessionId,
            kind: kind,
            date: now(),
            attempts: attempts,
            bodyMass: kind.estimatesPower ? bodyMass : nil,
            boxHeight: kind.usesBoxHeight ? boxHeight : nil
        )
    }
}
