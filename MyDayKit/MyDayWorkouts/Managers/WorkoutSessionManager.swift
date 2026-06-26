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
    @Published public var loggedSets: [String: [WorkoutSetLog]] = [:]  // keyed by exerciseId
    @Published public var sessionStatus: WorkoutSessionStatus = .notStarted
    @Published public var restTimerSeconds: Int = 0
    @Published public var isRestTimerRunning: Bool = false

    // MARK: - Private

    private let sessionId: String
    private let startedAt: Date
    private var restTimerTask: Task<Void, Never>?

    // MARK: - Init

    public init(entry: DailyWorkoutEntry) {
        self.entry = entry
        self.sessionId = UUID().uuidString
        self.startedAt = Date()
    }

    // MARK: - Set Logging

    /// Log a completed set for a given exercise.
    public func logSet(_ log: WorkoutSetLog, for exerciseId: String) {
        var sets = loggedSets[exerciseId] ?? []
        sets.append(log)
        loggedSets[exerciseId] = sets
    }

    /// Remove a logged set.
    public func removeSet(_ log: WorkoutSetLog, for exerciseId: String) {
        loggedSets[exerciseId]?.removeAll { $0.id == log.id }
    }

    /// All logged sets for a given exercise, sorted by completion date.
    public func sets(for exerciseId: String) -> [WorkoutSetLog] {
        (loggedSets[exerciseId] ?? []).sorted { $0.completedAt < $1.completedAt }
    }

    /// Total sets logged across all exercises.
    public var totalSetsLogged: Int {
        loggedSets.values.reduce(0) { $0 + $1.count }
    }

    /// Total sets targeted across all exercises.
    public var totalSetsTargeted: Int {
        entry.template.exercises.reduce(0) { $0 + $1.sets.count }
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
        sessionStatus = .inProgress
        entry.status = .inProgress
    }

    /// Build the final session model. Call when the user taps Finish.
    public func finishSession() -> WorkoutSessionModel {
        sessionStatus = .completed
        entry.status = .completed
        cancelRestTimer()

        return WorkoutSessionModel(
            id: sessionId,
            templateId: entry.template.id,
            userId: entry.template.createdBy,
            title: entry.template.title,
            startedAt: startedAt,
            completedAt: Date(),
            notes: nil,
            status: .completed
        )
    }

    /// Mark as incomplete without finishing fully.
    public func abandonSession() -> WorkoutSessionModel {
        sessionStatus = .abandoned
        entry.status = .incomplete
        cancelRestTimer()

        return WorkoutSessionModel(
            id: sessionId,
            templateId: entry.template.id,
            userId: entry.template.createdBy,
            title: entry.template.title,
            startedAt: startedAt,
            completedAt: Date(),
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
