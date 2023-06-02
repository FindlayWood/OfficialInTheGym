//
//  File.swift
//  
//
//  Created by Findlay-Personal on 10/05/2023.
//

import Foundation

enum Sport: String, Codable, CaseIterable {
    case rugby
    case basketball
    
    var positions: [Positions] {
        switch self {
        case .rugby:
            return Positions.allCases.filter { $0.sport == self }
        case .basketball:
            return Positions.allCases.filter { $0.sport == self }
        }
    }
    
    var starters: Int {
        switch self {
        case .rugby:
            return 15
        case .basketball:
            return 5
        }
    }
    
    var subs: Int {
        switch self {
        case .rugby:
            return 8
        case .basketball:
            return 7
        }
    }
}

enum Positions: String, Codable, CaseIterable {
    case looseheadProp
    case hooker
    case tightheadProp
    case secondRow
    case opensideFlanker
    case blindsideFlanker
    case numberEight
    case scrumHalf
    case flyHalf
    case winger
    case insideCentre
    case outsideCentre
    case fullback
    
    case pointGuard
    case shootingGuard
    
    var sport: Sport {
        switch self {
        case .looseheadProp, .hooker, .tightheadProp, .secondRow, .blindsideFlanker, .opensideFlanker, .numberEight,
                .scrumHalf, .flyHalf, .winger, .insideCentre, .outsideCentre, .fullback:
            return .rugby
        case .pointGuard, .shootingGuard:
            return .basketball
        }
    }
    
    var title: String {
        switch self {
        case .hooker, .winger, .fullback , .scrumHalf, .flyHalf:
            return self.rawValue.capitalized
        case .secondRow:
            return "Second Row"
        case .pointGuard:
            return "Point Guard"
        case .shootingGuard:
            return "Shooting Guard"
        case .looseheadProp:
            return "Loosehead Prop"
        case .tightheadProp:
            return "Tighthead Prop"
        case .opensideFlanker:
            return "Openside Flanker"
        case .blindsideFlanker:
            return "Blindside Flanker"
        case .numberEight:
            return "Number Eight"
        case .insideCentre:
            return "Inside Centre"
        case .outsideCentre:
            return "Outside Centre"
        }
    }
}
