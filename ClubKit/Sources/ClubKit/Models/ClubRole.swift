//
//  File.swift
//  
//
//  Created by Findlay-Personal on 11/05/2023.
//

import Foundation

enum ClubRole: String, Codable, CaseIterable {
    case player
    case manager
    
    var iconName: String {
        switch self {
        case .player:
            return "figure.run"
        case .manager:
            return "list.clipboard"
        }
    }
}
