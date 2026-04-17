//
//  WellnessQuestion.swift
//  MyDayKit
//
//  Created by Findlay Wood on 16/04/2026.
//

import Foundation

// MARK: - WellnessQuestion
struct WellnessQuestion: Identifiable {
    let id: String
    let emoji: String
    let title: String
    let subtitle: String
    let labels: [String] // 5 labels, index 0 = score 1

    static let all: [WellnessQuestion] = [
        WellnessQuestion(
            id: "sleep",
            emoji: "😴",
            title: "How did you sleep?",
            subtitle: "Quality and duration",
            labels: ["Terrible", "Poor", "OK", "Good", "Great"]
        ),
        WellnessQuestion(
            id: "physical",
            emoji: "💪",
            title: "How does your body feel?",
            subtitle: "Soreness and energy",
            labels: ["Very sore", "Sore", "Neutral", "Fresh", "Excellent"]
        ),
        WellnessQuestion(
            id: "mental",
            emoji: "🧠",
            title: "How is your focus?",
            subtitle: "Motivation and mental energy",
            labels: ["Drained", "Low", "Neutral", "Motivated", "Locked in"]
        ),
        WellnessQuestion(
            id: "mood",
            emoji: "☀️",
            title: "How are you feeling overall?",
            subtitle: "General wellbeing",
            labels: ["Very low", "Low", "Neutral", "Good", "Great"]
        )
    ]
}
