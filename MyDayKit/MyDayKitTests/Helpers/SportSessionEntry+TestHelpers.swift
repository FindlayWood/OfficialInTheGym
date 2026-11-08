//
//  SportSessionEntry+TestHelpers.swift
//  MyDayKitTests
//
//  Created by Findlay Wood on 05/11/2026.
//

import Foundation
@testable import MyDayKit

extension SportSessionEntry {

    static func basketballGame(id: String = "game", performedAt: Date = Date(timeIntervalSince1970: 1_800_000_000)) -> SportSessionEntry {
        SportSessionEntry(
            id: id,
            sport: .basketball,
            sessionType: .game,
            performedAt: performedAt,
            duration: 5_400,
            playingTime: 2_400,
            rpe: 7,
            result: .win,
            teamScore: 68,
            opponentScore: 61,
            note: nil
        )
    }

    static func golfRound(id: String = "golf", performedAt: Date = Date(timeIntervalSince1970: 1_800_000_000)) -> SportSessionEntry {
        SportSessionEntry(
            id: id,
            sport: .golf,
            sessionType: .training,
            performedAt: performedAt,
            duration: 14_400,
            playingTime: nil,
            rpe: 3,
            result: nil,
            teamScore: nil,
            opponentScore: nil,
            note: nil
        )
    }
}
