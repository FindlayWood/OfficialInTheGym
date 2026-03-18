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
    
    var title: String {
        switch self {
        case .rugby:
            return "Rugby"
        case .basketball:
            return "Basketball"
        }
    }
    var iconName: String {
        switch self {
        case .rugby:
            return "figure.rugby"
        case .basketball:
            return "figure.basketball"
        }
    }
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
    case smallForward
    case powerForward
    case center
    
    var sport: Sport {
        switch self {
        case .looseheadProp, .hooker, .tightheadProp, .secondRow, .blindsideFlanker, .opensideFlanker, .numberEight,
                .scrumHalf, .flyHalf, .winger, .insideCentre, .outsideCentre, .fullback:
            return .rugby
        case .pointGuard, .shootingGuard, .smallForward, .powerForward, .center:
            return .basketball
        }
    }
    
    var title: String {
        switch self {
        case .hooker, .winger, .fullback , .scrumHalf, .flyHalf, .center:
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
        case .smallForward:
            return "Small Forward"
        case .powerForward:
            return "Power Forward"
        }
    }
}
