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
}

enum Positions: String, Codable, CaseIterable {
    case prop
    case hooker
    case secondRow
    
    case pointGuard
    case shootingGuard
    
    var sport: Sport {
        switch self {
        case .prop, .hooker, .secondRow:
            return .rugby
        case .pointGuard, .shootingGuard:
            return .basketball
        }
    }
}
