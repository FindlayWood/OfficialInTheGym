//
//  WellnessEntry.swift
//  MyDayKit
//
//  Created by Findlay Wood on 16/04/2026.
//

import Foundation

// MARK: - WellnessEntry
public struct WellnessEntry: Codable, Identifiable {
    public let id: String
    public let date: Date
    public let sleepQuality: WellnessScore
    public let physicalReadiness: WellnessScore
    public let mentalEnergy: WellnessScore
    public let overallMood: WellnessScore

    public init(
        id: String = UUID().uuidString,
        date: Date = .now,
        sleepQuality: WellnessScore,
        physicalReadiness: WellnessScore,
        mentalEnergy: WellnessScore,
        overallMood: WellnessScore
    ) {
        self.id = id
        self.date = date
        self.sleepQuality = sleepQuality
        self.physicalReadiness = physicalReadiness
        self.mentalEnergy = mentalEnergy
        self.overallMood = overallMood
    }

    // 0–1 normalised average across all four scores
    public var readinessScore: Double {
        let scores = [sleepQuality, physicalReadiness, mentalEnergy, overallMood]
        let total = scores.reduce(0) { $0 + $1.rawValue }
        return Double(total) / Double(scores.count * WellnessScore.max.rawValue)
    }

    public var readinessLevel: ReadinessLevel {
        ReadinessLevel(score: readinessScore)
    }
}

// MARK: - WellnessScore
public enum WellnessScore: Int, CaseIterable, Codable {
    case one = 1, two, three, four, five

    public static let max: WellnessScore = .five

    public var label: String {
        // Generic fallback — question-specific labels applied at the view level
        switch self {
        case .one:   return "1"
        case .two:   return "2"
        case .three: return "3"
        case .four:  return "4"
        case .five:  return "5"
        }
    }
}

// MARK: - ReadinessLevel
public enum ReadinessLevel {
    case low, moderate, good, excellent

    public init(score: Double) {
        switch score {
        case 0..<0.4:  self = .low
        case 0.4..<0.6: self = .moderate
        case 0.6..<0.8: self = .good
        default:        self = .excellent
        }
    }

    public var label: String {
        switch self {
        case .low:       return "Low readiness"
        case .moderate:  return "Moderate readiness"
        case .good:      return "Good readiness"
        case .excellent: return "Excellent readiness"
        }
    }

    public var suggestion: String {
        switch self {
        case .low:       return "Consider a rest day or light recovery session."
        case .moderate:  return "Keep intensity moderate today."
        case .good:      return "Good to train. Listen to your body."
        case .excellent: return "You're primed to train hard today."
        }
    }
}
