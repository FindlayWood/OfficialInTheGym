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

    // MARK: - Private

    private let sessionId: String
    public private(set) var startedAt: Date = Date()
    private var restTimerTask: Task<Void, Never>?

    // MARK: - Init

    public init(entry: DailyWorkoutEntry) {
        self.entry = entry
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
        distanceUnit: DistanceUnit?
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
        record.exerciseRecords[exIdx].setRecords[setIdx].completedAt = Date()

        sessionRecord = record
        entry.sessionRecord = record
        onEntryUpdated?(entry)
    }

    /// Return a set to un-logged, discarding the performed values.
    public func uncompleteSet(exerciseId: String, setId: String) {
        guard var record = sessionRecord else { return }
        guard let exIdx = record.exerciseRecords.firstIndex(where: { $0.exerciseId == exerciseId }) else { return }
        guard let setIdx = record.exerciseRecords[exIdx].setRecords.firstIndex(where: { $0.id == setId }) else { return }

        record.exerciseRecords[exIdx].setRecords[setIdx].isCompleted = false
        record.exerciseRecords[exIdx].setRecords[setIdx].reps = nil
        record.exerciseRecords[exIdx].setRecords[setIdx].weight = nil
        record.exerciseRecords[exIdx].setRecords[setIdx].weightUnit = nil
        record.exerciseRecords[exIdx].setRecords[setIdx].time = nil
        record.exerciseRecords[exIdx].setRecords[setIdx].distance = nil
        record.exerciseRecords[exIdx].setRecords[setIdx].distanceUnit = nil
        record.exerciseRecords[exIdx].setRecords[setIdx].completedAt = nil

        sessionRecord = record
        entry.sessionRecord = record
        onEntryUpdated?(entry)
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

        return WorkoutSessionModel(
            id: sessionId,
            templateId: entry.template.id,
            userId: entry.template.createdBy,
            title: entry.template.title,
            startedAt: startedAt,
            completedAt: endedAt,
            notes: notes,
            status: .completed
        )
    }

    /// Mark as incomplete without finishing fully.
    public func abandonSession() -> WorkoutSessionModel {
        let endedAt = Date()
        sessionStatus = .abandoned
        entry.status = .incomplete
        cancelRestTimer()

        if var record = sessionRecord {
            record.endedAt = endedAt
            sessionRecord = record
            entry.sessionRecord = record
        }

        onEntryUpdated?(entry)

        return WorkoutSessionModel(
            id: sessionId,
            templateId: entry.template.id,
            userId: entry.template.createdBy,
            title: entry.template.title,
            startedAt: startedAt,
            completedAt: endedAt,
            notes: nil,
            status: .abandoned
        )
    }
}

// MARK: - Session Status

public enum WorkoutSessionStatus {
    case notStarted
    case inProgress
    case completed
    case abandoned
}
