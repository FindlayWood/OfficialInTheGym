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

    var onRecordAttempt: (() -> Void)?
    var onFinished: ((JumpTestSession) -> Void)?
    var onCancel: (() -> Void)?

    private let writer: JumpTestSessionWriter
    private let sessionId: String
    private let now: () -> Date

    init(kind: JumpTestKind, writer: JumpTestSessionWriter, now: @escaping () -> Date = Date.init, makeId: () -> String = { UUID().uuidString }) {
        self.kind = kind
        self.writer = writer
        self.now = now
        self.sessionId = makeId()
    }

    var canRecordMore: Bool {
        attempts.count < kind.attempts
    }

    var canSave: Bool {
        !attempts.isEmpty
    }

    /// The position of the highest attempt. The first of equal heights, so the
    /// marker does not jump to a later attempt that only matched it.
    var bestIndex: Int? {
        guard let best = attempts.map(\.height).max() else { return nil }
        return attempts.firstIndex { $0.height == best }
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
        let session = JumpTestSession(id: sessionId, kind: kind, date: now(), attempts: attempts)
        do {
            try await writer.write(session)
            onFinished?(session)
        } catch {
            print("❌ \(kind.title) session save failed: \(error)")
            saveError = "Your jumps couldn't be saved. Check your connection and try again."
        }
    }
}
