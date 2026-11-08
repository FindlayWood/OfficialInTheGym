//
//  MyDayNewSportManager.swift
//  MyDayKit
//
//  Created by Findlay Wood on 11/03/2026.
//

import Foundation

class MyDayNewSportManager: ObservableObject, Hashable {
    
    let sport: SportType
    
    @Published var sessionType: SportSessionType = .training
    @Published var duration: Int = 0          // total session/game duration in seconds
    @Published var playingTime: Int = 0       // actual playing time in seconds
    @Published var rpe: Int?
    @Published var result: GameResult?
    @Published var homeScore: Int?
    @Published var awayScore: Int?
    @Published var note: String?
    
    var sessionLoad: Double? {
        SportSessionEntry.sessionLoad(type: sessionType, duration: duration, playingTime: playingTime, rpe: rpe)
    }

    /// The form as the session it records. Game-only answers (playing time, result, scores) are
    /// dropped for training, so switching the type back after filling them in cannot leave a
    /// training session carrying a scoreline. A blank note is no note.
    func makeEntry(id: String = UUID().uuidString, performedAt: Date = .now) -> SportSessionEntry {
        let isGame = sessionType == .game
        let trimmedNote = note?.trimmingCharacters(in: .whitespacesAndNewlines)
        return SportSessionEntry(
            id: id,
            sport: sport,
            sessionType: sessionType,
            performedAt: performedAt,
            duration: duration,
            playingTime: isGame && playingTime > 0 ? playingTime : nil,
            rpe: rpe,
            result: isGame ? result : nil,
            teamScore: isGame ? homeScore : nil,
            opponentScore: isGame ? awayScore : nil,
            note: trimmedNote?.isEmpty == false ? trimmedNote : nil
        )
    }
    
    init(sport: SportType) {
        self.sport = sport
    }
    
    // MARK: - Hashable
    static func == (lhs: MyDayNewSportManager, rhs: MyDayNewSportManager) -> Bool {
        lhs === rhs
    }
    
    func hash(into hasher: inout Hasher) {
        hasher.combine(ObjectIdentifier(self))
    }
}
