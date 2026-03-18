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
        guard let rpe else { return nil }
        let relevantTime: Int
        switch sessionType {
        case .training: relevantTime = duration
        case .game:     relevantTime = playingTime > 0 ? playingTime : duration
        }
        guard relevantTime > 0 else { return nil }
        return (Double(relevantTime) / 60.0) * Double(rpe)
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
