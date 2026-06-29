//
//  ExerciseCategory.swift
//  MyDayKit
//
//  Created by Findlay Wood on 05/08/2025.
//

import SwiftUI

public enum ExerciseCategory: String, CaseIterable, Codable {
    case upperBody = "upper_body"
    case lowerBody = "lower_body"
    case core = "core"
    case cardio = "cardio"
    case fullBody = "full_body"
    
    var title: String {
        switch self {
        case .upperBody:
            return "Upper Body"
        case .lowerBody:
            return "Lower Body"
        case .core:
            return "Core"
        case .cardio:
            return "Cardio"
        case .fullBody:
            return "Full Body"
        }
    }
    
    var color: Color {
        switch self {
        case .upperBody:  return .blue
        case .lowerBody:  return .green
        case .core:       return .orange
        case .cardio:     return .red
        case .fullBody:   return .purple
        }
    }
}
