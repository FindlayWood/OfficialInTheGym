//
//  WorkoutSessionManager.swift
//  MyDayKit
//
//  Created by Findlay Wood on 15/06/2026.
//

import Foundation

public final class WorkoutSessionManager: ObservableObject, @unchecked Sendable {

    // MARK: - Published State

    @Published public var entry: DailyWorkoutEntry
    @Published public var sessionRecord: WorkoutSessionRecord?
    @Published public var sessionStatus: WorkoutSessionStatus = .notStarted
    @Published public var restTimerSeconds: Int = 0
    @Published public var isRestTimerRunning: Bool = false

    // MARK: - Callbacks

    public var onEntryUpdated: ((DailyWorkoutEntry) -> Void)?

    /// Fired when a set is logged, carrying its raw stats log.
    ///
    /// A set performed in a session is the same event as an exercise logged on
    /// its own, so it writes to the same `ExerciseStats/{id}/RawLogs`
    /// collection. Kept separate from `onEntryUpdated` because that fires for
    /// start, finish and cancel too, where no set was performed.
    public var onSetLogged: ((ExerciseStatsSaveModel) -> Void)?

    /// Fired when a logged set is discarded — un-logged individually, or thrown
    /// away with the whole session — carrying what addresses its raw log.
    public var onSetUnlogged: ((_ exerciseId: String, _ logId: String) -> Void)?

    /// Fired once the session is finished, carrying it as a document of its own
    /// for the analytics collection and the user's history. Unlike a set's raw
    /// log, this is written on finish rather than as work happens — a session
    /// only means something complete.
    public var onSessionFinished: ((CompletedWorkoutSession) -> Void)?

    // MARK: - Private

    private var sessionId: String

    /// Who is performing the session. Deliberately injected rather than read off
    /// `entry.template.createdBy` — that is the template's *author*, which for a
    /// coach-programmed workout is not the person doing it.
    private let userId: String

    public private(set) var startedAt: Date = Date()
    private var restTimerTask: Task<Void, Never>?

    // MARK: - Init

    public init(entry: DailyWorkoutEntry, userId: String) {
        self.entry = entry
        self.userId = userId
        if let record = entry.sessionRecord, entry.status == .inProgress || entry.status == .completed {
            self.sessionId = record.id
            self.startedAt = entry.startedAt ?? record.startedAt
            self.sessionStatus = entry.status == .completed ? .completed : .inProgress
            self.sessionRecord = record
        } else {
            self.sessionId = UUID().uuidString
        }
    }

    // MARK: - Set Completion

    /// Mark a template set as completed and store the actual performed values.
    public func completeSet(
        exerciseId: String,
        setId: String,
        reps: Int?,
        weight: Double?,
        weightUnit: WeightUnit?,
        time: Int?,
        distance: Double?,
        distanceUnit: DistanceUnit?,
        tempo: Tempo? = nil,
        note: String? = nil
    ) {
        guard var record = sessionRecord else { return }
        guard let exIdx = record.exerciseRecords.firstIndex(where: { $0.exerciseId == exerciseId }) else { return }
        guard let setIdx = record.exerciseRecords[exIdx].setRecords.firstIndex(where: { $0.id == setId }) else { return }

        record.exerciseRecords[exIdx].setRecords[setIdx].isCompleted = true
        record.exerciseRecords[exIdx].setRecords[setIdx].reps = reps
        record.exerciseRecords[exIdx].setRecords[setIdx].weight = weight
        record.exerciseRecords[exIdx].setRecords[setIdx].weightUnit = weightUnit
        record.exerciseRecords[exIdx].setRecords[setIdx].time = time
        record.exerciseRecords[exIdx].setRecords[setIdx].distance = distance
        record.exerciseRecords[exIdx].setRecords[setIdx].distanceUnit = distanceUnit
        record.exerciseRecords[exIdx].setRecords[setIdx].tempo = tempo
        record.exerciseRecords[exIdx].setRecords[setIdx].note = note
        record.exerciseRecords[exIdx].setRecords[setIdx].completedAt = Date()

        sessionRecord = record
        entry.sessionRecord = record
        onEntryUpdated?(entry)

        // Re-logging an already-logged set rewrites the same raw log document,
        // so an edit corrects the stats rather than adding a second entry.
        let exerciseRecord = record.exerciseRecords[exIdx]
        onSetLogged?(
            exerciseRecord.setRecords[setIdx].getStats(
                exerciseId: exerciseRecord.exerciseId,
                exerciseName: exerciseRecord.exerciseName,
                sessionId: sessionId
            )
        )
    }

    /// Return a set to un-logged, discarding the performed values.
    public func uncompleteSet(exerciseId: String, setId: String) {
        guard var record = sessionRecord else { return }
        guard let exIdx = record.exerciseRecords.firstIndex(where: { $0.exerciseId == exerciseId }) else { return }
        guard let setIdx = record.exerciseRecords[exIdx].setRecords.firstIndex(where: { $0.id == setId }) else { return }

        // A set that was never logged wrote no raw log to remove.
        let wasLogged = record.exerciseRecords[exIdx].setRecords[setIdx].isCompleted

        record.exerciseRecords[exIdx].setRecords[setIdx].isCompleted = false
        record.exerciseRecords[exIdx].setRecords[setIdx].reps = nil
        record.exerciseRecords[exIdx].setRecords[setIdx].weight = nil
        record.exerciseRecords[exIdx].setRecords[setIdx].weightUnit = nil
        record.exerciseRecords[exIdx].setRecords[setIdx].time = nil
        record.exerciseRecords[exIdx].setRecords[setIdx].distance = nil
        record.exerciseRecords[exIdx].setRecords[setIdx].distanceUnit = nil
        record.exerciseRecords[exIdx].setRecords[setIdx].tempo = nil
        record.exerciseRecords[exIdx].setRecords[setIdx].note = nil
        record.exerciseRecords[exIdx].setRecords[setIdx].completedAt = nil

        sessionRecord = record
        entry.sessionRecord = record
        onEntryUpdated?(entry)

        if wasLogged {
            onSetUnlogged?(
                record.exerciseRecords[exIdx].exerciseId,
                WorkoutSetRecord.statsLogId(sessionId: sessionId, setId: setId)
            )
        }
    }

    /// The stored record for a single set, if the session has started.
    public func setRecord(exerciseId: String, setId: String) -> WorkoutSetRecord? {
        setRecords(for: exerciseId).first(where: { $0.id == setId })
    }

    /// All set records for a given exercise, in template order.
    public func setRecords(for exerciseId: String) -> [WorkoutSetRecord] {
        sessionRecord?.exerciseRecords.first(where: { $0.exerciseId == exerciseId })?.setRecords ?? []
    }

    /// RPE logged for a given exercise, if set.
    public func exerciseRPE(for exerciseId: String) -> Int? {
        sessionRecord?.exerciseRecords.first(where: { $0.exerciseId == exerciseId })?.rpe
    }

    /// Set the RPE for a specific exercise and persist.
    public func setExerciseRPE(exerciseId: String, rpe: Int) {
        guard var record = sessionRecord else { return }
        guard let idx = record.exerciseRecords.firstIndex(where: { $0.exerciseId == exerciseId }) else { return }
        record.exerciseRecords[idx].rpe = rpe
        sessionRecord = record
        entry.sessionRecord = record
        onEntryUpdated?(entry)
    }

    /// Total sets marked completed across all exercises.
    public var totalSetsLogged: Int {
        sessionRecord?.exerciseRecords.flatMap(\.setRecords).filter(\.isCompleted).count ?? 0
    }

    /// Total sets targeted across all exercises.
    public var totalSetsTargeted: Int {
        entry.template.exercises.reduce(0) { $0 + $1.sets.count }
    }

    /// Average RPE across exercises that have one logged, nil if none logged.
    public var averageExerciseRPE: Double? {
        let values = sessionRecord?.exerciseRecords.compactMap(\.rpe) ?? []
        guard !values.isEmpty else { return nil }
        return Double(values.reduce(0, +)) / Double(values.count)
    }

    // MARK: - Rest Timer

    public func startRestTimer(seconds: Int) {
        restTimerTask?.cancel()
        restTimerSeconds = seconds
        isRestTimerRunning = true

        restTimerTask = Task { @MainActor in
            while restTimerSeconds > 0 {
                try? await Task.sleep(nanoseconds: 1_000_000_000)
                guard !Task.isCancelled else { break }
                restTimerSeconds -= 1
            }
            isRestTimerRunning = false
        }
    }

    public func cancelRestTimer() {
        restTimerTask?.cancel()
        restTimerSeconds = 0
        isRestTimerRunning = false
    }

    // MARK: - Session Control

    public func startSession() {
        startedAt = Date()
        sessionStatus = .inProgress
        entry.status = .inProgress
        entry.startedAt = startedAt

        let record = WorkoutSessionRecord(
            id: sessionId,
            startedAt: startedAt,
            exerciseRecords: entry.template.exercises.map { exercise in
                WorkoutExerciseRecord(
                    id: exercise.id,
                    exerciseId: exercise.exerciseId,
                    exerciseName: exercise.exerciseName,
                    setRecords: exercise.sets.map { set in
                        WorkoutSetRecord(id: set.id, isCompleted: false)
                    }
                )
            }
        )
        sessionRecord = record
        entry.sessionRecord = record
        onEntryUpdated?(entry)
    }

    /// Finalise the session record. Called when the user confirms on the summary screen.
    @discardableResult
    public func finishSession(rpe: Int?, notes: String?) -> WorkoutSessionModel {
        let endedAt = Date()
        sessionStatus = .completed
        entry.status = .completed
        cancelRestTimer()

        if var record = sessionRecord {
            record.endedAt = endedAt
            record.rpe = rpe
            record.notes = notes
            if let rpe = rpe {
                let minutes = endedAt.timeIntervalSince(startedAt) / 60.0
                record.workload = minutes * Double(rpe)
            }
            sessionRecord = record
            entry.sessionRecord = record
        }

        onEntryUpdated?(entry)

        if let record = sessionRecord {
            onSessionFinished?(completedSession(from: record, endedAt: endedAt))
        }

        return WorkoutSessionModel(
            id: sessionId,
            templateId: entry.template.id,
            userId: userId,
            title: entry.template.title,
            startedAt: startedAt,
            completedAt: endedAt,
            notes: notes,
            status: .completed
        )
    }

    /// The finished session as its own document.
    private func completedSession(from record: WorkoutSessionRecord, endedAt: Date) -> CompletedWorkoutSession {
        CompletedWorkoutSession(
            id: sessionId,
            userId: userId,
            templateId: entry.template.id,
            title: entry.template.title,
            assignedDate: entry.assignedDate,
            startedAt: startedAt,
            endedAt: endedAt,
            durationSeconds: Int(endedAt.timeIntervalSince(startedAt)),
            rpe: record.rpe,
            workload: record.workload,
            notes: record.notes,
            setsCompleted: totalSetsLogged,
            setsTargeted: totalSetsTargeted,
            exerciseRecords: record.exerciseRecords,
            assignedBy: entry.assignedBy,
            assignmentId: entry.assignmentId
        )
    }

    /// Reset the workout to as though it had never been started — the record
    /// and every logged set are discarded and the entry returns to `.planned`.
    ///
    /// This is deliberately a full reset rather than a "mark incomplete": the
    /// workout stays on the day and can be started again, and removing it
    /// altogether is a separate action on the MyDay home screen.
    public func cancelSession() {
        cancelRestTimer()

        // Discarding the session discards its raw logs too — a workout the user
        // threw away must not go on counting toward exercise stats. Done before
        // the session id is regenerated, since that id addresses the logs.
        if let record = sessionRecord {
            for exerciseRecord in record.exerciseRecords {
                for set in exerciseRecord.setRecords where set.isCompleted {
                    onSetUnlogged?(
                        exerciseRecord.exerciseId,
                        WorkoutSetRecord.statsLogId(sessionId: sessionId, setId: set.id)
                    )
                }
            }
        }

        // A restart is a new session, so it must not reuse the cancelled id.
        sessionId = UUID().uuidString
        startedAt = Date()

        sessionStatus = .notStarted
        sessionRecord = nil

        entry.status = .planned
        entry.sessionId = nil
        entry.startedAt = nil
        entry.sessionRecord = nil

        onEntryUpdated?(entry)
    }
}

// MARK: - Session Status

public enum WorkoutSessionStatus {
    case notStarted
    case inProgress
    case completed
}
