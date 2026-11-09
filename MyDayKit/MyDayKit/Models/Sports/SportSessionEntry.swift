//
//  SportSessionEntry.swift
//  MyDayKit
//
//  Created by Findlay Wood on 05/11/2026.
//

import Foundation

/// A sport session the user played or trained — a basketball game, a round of golf — as it is
/// stored. The same value lives in **two** places: embedded in the day
/// (`MyDayFullDayModel.sports`), which is what MyDay reads and what keeps it local-first, and as
/// a document of its own (`SportSessionSaver`), which is what stats and a future sport history
/// read without opening every day of every user. The pattern is the one completed workouts
/// already follow.
///
/// **Every field a later version might add must be optional.** This is embedded in every day
/// file and day document that holds a sport; a non-optional field added later fails to decode
/// all of them — the Firestore decode warning under *Workout Library Loading* in CLAUDE.md.
///
/// Scores are the user's side and the other side, never home and away: the user logs from
/// their own point of view, and an away game would otherwise read back the wrong way round.
public struct SportSessionEntry: Identifiable, Codable, Equatable, Sendable {
    public let id: String
    public let sport: SportType
    public let sessionType: SportSessionType
    public let performedAt: Date
    /// Seconds. The whole session for training, the whole game for a game.
    public let duration: Int
    /// Seconds on the field or court. Games only; `nil` for training.
    public let playingTime: Int?
    public let rpe: Int?
    public let result: GameResult?
    public let teamScore: Int?
    public let opponentScore: Int?
    public let note: String?
    /// The schedule this session was logged from, or `nil` if the user added it. Stops the due card
    /// being drawn beside the session it became. Optional, as the note at the top of this type says.
    public let scheduleId: String?

    public init(
        id: String,
        sport: SportType,
        sessionType: SportSessionType,
        performedAt: Date,
        duration: Int,
        playingTime: Int?,
        rpe: Int?,
        result: GameResult?,
        teamScore: Int?,
        opponentScore: Int?,
        note: String?,
        scheduleId: String? = nil
    ) {
        self.id = id
        self.sport = sport
        self.sessionType = sessionType
        self.performedAt = performedAt
        self.duration = duration
        self.playingTime = playingTime
        self.rpe = rpe
        self.result = result
        self.teamScore = teamScore
        self.opponentScore = opponentScore
        self.note = note
        self.scheduleId = scheduleId
    }

    /// Duration in minutes × RPE — the same session load a workout carries as `workload`.
    public var sessionLoad: Double? {
        Self.sessionLoad(type: sessionType, duration: duration, playingTime: playingTime ?? 0, rpe: rpe)
    }

    /// **The one definition of a sport session's load**, shared by the form while it is being
    /// filled in (`MyDayNewSportManager`) and the stored entry, so the number shown before saving
    /// is the number saved.
    ///
    /// A game counts the time actually played, not the time at the venue: forty minutes on the
    /// bench is not training load. With no playing time it falls back to the game's duration
    /// rather than reading zero. No RPE, or no time, is no load — `nil`, never `0`, because zero
    /// would claim a session that was measured and was easy.
    ///
    /// Must stay in step with the Cloud Function that adds sport load to `DailyTotal.totalWorkload`.
    public static func sessionLoad(type: SportSessionType, duration: Int, playingTime: Int, rpe: Int?) -> Double? {
        guard let rpe else { return nil }
        let relevantTime: Int
        switch type {
        case .training: relevantTime = duration
        case .game:     relevantTime = playingTime > 0 ? playingTime : duration
        }
        guard relevantTime > 0 else { return nil }
        return (Double(relevantTime) / 60.0) * Double(rpe)
    }
}
