//
//  SportType.swift
//  MyDayKit
//
//  Created by Findlay Wood on 09/03/2026.
//

import SwiftUI

// MARK: - Sport Type

enum SportType: String, CaseIterable, Codable, Identifiable {
    
    // Team
    case basketball        = "Basketball"
    case football          = "Football"
    case americanFootball  = "American Football"
    case rugbyUnion        = "Rugby Union"
    case rugbyLeague       = "Rugby League"
    case iceHockey         = "Ice Hockey"
    case fieldHockey       = "Field Hockey"
    case baseball          = "Baseball"
    case softball          = "Softball"
    case volleyball        = "Volleyball"
    case handball          = "Handball"
    case lacrosse          = "Lacrosse"
    case cricket           = "Cricket"
    case netball           = "Netball"
    case waterPolo         = "Water Polo"
    case aussieRules       = "Aussie Rules"
    
    // Racket
    case tennis            = "Tennis"
    case badminton         = "Badminton"
    case squash            = "Squash"
    case tableTennis       = "Table Tennis"
    case padel             = "Padel"
    case pickleball        = "Pickleball"
    
    // Combat
    case boxing            = "Boxing"
    case mma               = "MMA"
    case wrestling         = "Wrestling"
    case judo              = "Judo"
    case bjj               = "Brazilian Jiu-Jitsu"
    case karate            = "Karate"
    case taekwondo         = "Taekwondo"
    case muayThai          = "Muay Thai"
    case kickboxing        = "Kickboxing"
    case fencing           = "Fencing"
    
    // Individual
    case golf              = "Golf"
    case athletics         = "Athletics"
    case competitiveSwim   = "Swimming"
    case gymnastics        = "Gymnastics"
    case diving            = "Diving"
    case weightlifting     = "Weightlifting"
    case powerlifting      = "Powerlifting"
    case crossfit          = "CrossFit"
    case triathlon         = "Triathlon"
    case duathlon          = "Duathlon"
    
    // Outdoor
    case roadCycling       = "Road Cycling"
    case mtbCycling        = "MTB Cycling"
    case surfing           = "Surfing"
    case skateboarding     = "Skateboarding"
    case snowboarding      = "Snowboarding"
    case skiing            = "Skiing"
    case climbing          = "Climbing"
    case kayaking          = "Kayaking"
    case competitiveRowing = "Rowing"
    case sailing           = "Sailing"
    
    // Other
    case cheerleading      = "Cheerleading"
    case danceSport        = "Dance"
    case esports           = "Esports"
    case other             = "Other"
    
    var id: String { rawValue }
    
    var icon: String {
        switch self {
        case .basketball:        return "basketball.fill"
        case .football:          return "soccerball"
        case .americanFootball:  return "football.fill"
        case .rugbyUnion,
             .rugbyLeague:       return "rugby.ball.fill"
        case .iceHockey:         return "hockey.puck.fill"
        case .fieldHockey:       return "sportscourt.fill"
        case .baseball,
             .softball:          return "baseball.fill"
        case .volleyball:        return "volleyball.fill"
        case .handball,
             .lacrosse,
             .netball,
             .waterPolo,
             .aussieRules:       return "sportscourt.fill"
        case .cricket:           return "cricket.ball.fill"
        case .tennis:            return "tennis.racket"
        case .badminton:         return "tennis.racket"
        case .squash,
             .padel,
             .pickleball:        return "tennis.racket"
        case .tableTennis:       return "tennis.racket"
        case .boxing,
             .kickboxing,
             .muayThai:          return "figure.boxing"
        case .mma:               return "figure.martial.arts"
        case .wrestling,
             .judo,
             .bjj,
             .karate,
             .taekwondo:         return "figure.martial.arts"
        case .fencing:           return "figure.fencing"
        case .golf:              return "figure.golf"
        case .athletics:         return "figure.run"
        case .competitiveSwim:   return "figure.pool.swim"
        case .gymnastics:        return "figure.gymnastics"
        case .diving:            return "figure.diving"
        case .weightlifting,
             .powerlifting,
             .crossfit:          return "dumbbell.fill"
        case .triathlon,
             .duathlon:          return "figure.run"
        case .roadCycling,
             .mtbCycling:        return "figure.outdoor.cycle"
        case .surfing:           return "figure.surfing"
        case .skateboarding:     return "figure.skateboarding"
        case .snowboarding:      return "figure.snowboarding"
        case .skiing:            return "figure.skiing.downhill"
        case .climbing:          return "figure.climbing"
        case .kayaking:          return "figure.water.fitness"
        case .competitiveRowing: return "figure.rowing"
        case .sailing:           return "sailboat.fill"
        case .cheerleading:      return "sparkles"
        case .danceSport:        return "music.note"
        case .esports:           return "gamecontroller.fill"
        case .other:             return "ellipsis.circle"
        }
    }
    
    var color: Color {
        switch self {
        case .basketball:        return Color.orange
        case .football:          return Color.green
        case .americanFootball:  return Color.brown
        case .rugbyUnion,
             .rugbyLeague:       return Color.green
        case .iceHockey:         return Color.cyan
        case .fieldHockey:       return Color.green
        case .baseball,
             .softball:          return Color.red
        case .volleyball:        return Color.yellow
        case .handball,
             .lacrosse:          return Color.blue
        case .cricket:           return Color.green
        case .netball:           return Color.purple
        case .waterPolo:         return Color.cyan
        case .aussieRules:       return Color.yellow
        case .tennis:            return Color.yellow
        case .badminton:         return Color.green
        case .squash:            return Color.orange
        case .tableTennis:       return Color.blue
        case .padel,
             .pickleball:        return Color.green
        case .boxing,
             .kickboxing,
             .muayThai:          return Color.red
        case .mma:               return Color.red
        case .wrestling:         return Color.orange
        case .judo:              return Color.indigo
        case .bjj:               return Color.blue
        case .karate,
             .taekwondo:         return Color.red
        case .fencing:           return Color.gray
        case .golf:              return Color.green
        case .athletics:         return Color.blue
        case .competitiveSwim:   return Color.cyan
        case .gymnastics:        return Color.purple
        case .diving:            return Color.cyan
        case .weightlifting,
             .powerlifting:      return Color.blue
        case .crossfit:          return Color.orange
        case .triathlon,
             .duathlon:          return Color.teal
        case .roadCycling:       return Color.yellow
        case .mtbCycling:        return Color.brown
        case .surfing:           return Color.cyan
        case .skateboarding:     return Color.purple
        case .snowboarding:      return Color.blue
        case .skiing:            return Color.blue
        case .climbing:          return Color.brown
        case .kayaking:          return Color.cyan
        case .competitiveRowing: return Color.indigo
        case .sailing:           return Color.blue
        case .cheerleading:      return Color.pink
        case .danceSport:        return Color.purple
        case .esports:           return Color.indigo
        case .other:             return Color.gray
        }
    }
    
    var category: SportCategory {
        switch self {
        case .basketball, .football, .americanFootball,
             .rugbyUnion, .rugbyLeague, .iceHockey,
             .fieldHockey, .baseball, .softball,
             .volleyball, .handball, .lacrosse,
             .cricket, .netball, .waterPolo,
             .aussieRules:
            return .team
        case .tennis, .badminton, .squash,
             .tableTennis, .padel, .pickleball:
            return .racket
        case .boxing, .mma, .wrestling, .judo,
             .bjj, .karate, .taekwondo,
             .muayThai, .kickboxing, .fencing:
            return .combat
        case .golf, .athletics, .competitiveSwim,
             .gymnastics, .diving, .weightlifting,
             .powerlifting, .crossfit, .triathlon,
             .duathlon:
            return .individual
        case .roadCycling, .mtbCycling, .surfing,
             .skateboarding, .snowboarding, .skiing,
             .climbing, .kayaking, .competitiveRowing,
             .sailing:
            return .outdoor
        case .cheerleading, .danceSport,
             .esports, .other:
            return .other
        }
    }
}

enum SportCategory: String, CaseIterable {
    case team       = "Team"
    case racket     = "Racket"
    case combat     = "Combat"
    case individual = "Individual"
    case outdoor    = "Outdoor"
    case other      = "Other"
}

enum SportSessionType: String, CaseIterable, Codable {
    case training = "Training"
    case game     = "Game"
    
    var icon: String {
        switch self {
        case .training: return "figure.run.circle"
        case .game:     return "trophy.fill"
        }
    }
    
    var description: String {
        switch self {
        case .training: return "Practice or training session"
        case .game:     return "Competitive match or game"
        }
    }
}

enum GameResult: String, CaseIterable, Codable {
    case win  = "Win"
    case loss = "Loss"
    case draw = "Draw"
    
    var icon: String {
        switch self {
        case .win:  return "trophy.fill"
        case .loss: return "minus.circle.fill"
        case .draw: return "equal.circle.fill"
        }
    }
    
    var color: Color {
        switch self {
        case .win:  return .green
        case .loss: return .red
        case .draw: return .orange
        }
    }
}
