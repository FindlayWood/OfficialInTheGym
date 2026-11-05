//
//  SportSessionSummary.swift
//  MyDayKit
//
//  Created by Findlay Wood on 05/11/2026.
//

import Foundation

/// What a sport session's card says, worked out from the entry so the card holds no formatting
/// of its own and the wording can be tested.
///
/// The time shown is the time that counts toward load — playing time for a game that has one,
/// otherwise the duration — so the card never shows one number while stats use another. A game
/// says "played" beside it, since forty minutes of a ninety-minute game is otherwise a puzzle.
struct SportSessionSummary: Equatable {
    let label: String
    let title: String
    let subtitle: String
    /// "W 68–61", "Win" or "68–61" for a game with any of those; `nil` for training or a game
    /// with neither result nor score.
    let outcome: String?

    init(_ session: SportSessionEntry) {
        label = "SPORT · \(session.sessionType.rawValue.uppercased())"
        title = session.sport.rawValue

        var parts: [String] = []
        if let playingTime = session.playingTime, session.sessionType == .game {
            parts.append("\(Self.formatted(seconds: playingTime)) played")
        } else {
            parts.append(Self.formatted(seconds: session.duration))
        }
        if let rpe = session.rpe {
            parts.append("RPE \(rpe)")
        }
        subtitle = parts.joined(separator: " · ")

        outcome = Self.makeOutcome(for: session)
    }

    private static func makeOutcome(for session: SportSessionEntry) -> String? {
        guard session.sessionType == .game else { return nil }
        let score: String? = {
            guard let team = session.teamScore, let opponent = session.opponentScore else { return nil }
            return "\(team)–\(opponent)"
        }()
        switch (session.result, score) {
        case let (result?, score?): return "\(result.rawValue.prefix(1)) \(score)"
        case let (result?, nil):    return result.rawValue
        case let (nil, score?):     return score
        case (nil, nil):            return nil
        }
    }

    /// `1h 30m`, `45m`, `30s` — whole minutes once there are any, since a session is not timed
    /// to the second.
    static func formatted(seconds: Int) -> String {
        let hours = seconds / 3600
        let minutes = (seconds % 3600) / 60
        if hours > 0 { return minutes == 0 ? "\(hours)h" : "\(hours)h \(minutes)m" }
        if minutes > 0 { return "\(minutes)m" }
        return "\(seconds)s"
    }
}
