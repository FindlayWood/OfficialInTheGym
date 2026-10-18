//
//  WellnessQuestion.swift
//  MyDayKit
//
//  Created by Findlay Wood on 16/04/2026.
//

import Foundation

// MARK: - WellnessQuestion
/// One check-in question. **No emoji** — each question used to lead with one, the only ones
/// anywhere in MyDay, which made the check-in read as a different app and brought four colours of
/// their own beside the matte green. The question text says what it asks, and the timeline node
/// already marks the step as the check-in.
struct WellnessQuestion: Identifiable {
    let id: String
    let title: String
    let subtitle: String
    let labels: [String] // 5 labels, index 0 = score 1

    static let all: [WellnessQuestion] = [
        WellnessQuestion(
            id: "sleep",
            title: "How did you sleep?",
            subtitle: "Quality and duration",
            labels: ["Terrible", "Poor", "OK", "Good", "Great"]
        ),
        WellnessQuestion(
            id: "physical",
            title: "How does your body feel?",
            subtitle: "Soreness and energy",
            labels: ["Very sore", "Sore", "Neutral", "Fresh", "Excellent"]
        ),
        WellnessQuestion(
            id: "mental",
            title: "How is your focus?",
            subtitle: "Motivation and mental energy",
            labels: ["Drained", "Low", "Neutral", "Motivated", "Locked in"]
        ),
        WellnessQuestion(
            id: "mood",
            title: "How are you feeling overall?",
            subtitle: "General wellbeing",
            labels: ["Very low", "Low", "Neutral", "Good", "Great"]
        )
    ]
}
