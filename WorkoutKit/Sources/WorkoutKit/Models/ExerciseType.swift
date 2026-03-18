//
//  File.swift
//  
//
//  Created by Findlay-Personal on 22/04/2023.
//

import Foundation

enum ExerciseType: String, Codable {
    case upperBody
    case lowerBody
    case core
    case cardio
    
    var title: String {
        switch self {
        case .upperBody:
            return "UB"
        case .lowerBody:
            return "LB"
        case .core:
            return "CO"
        case .cardio:
            return "CA"
        }
    }
}
