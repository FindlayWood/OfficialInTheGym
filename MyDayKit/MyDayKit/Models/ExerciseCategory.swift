//
//  ExerciseCategory.swift
//  MyDayKit
//
//  Created by Findlay Wood on 05/08/2025.
//

import SwiftUI

enum ExerciseCategory: String, CaseIterable, Codable {
    case upperBody
    case lowerBody
    case core
    case cardio
    
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
        }
    }
    
    var color: Color {
        switch self {
        case .upperBody:  return .blue
        case .lowerBody:  return .green
        case .core:       return .orange
        case .cardio:     return .red
        }
    }
}
