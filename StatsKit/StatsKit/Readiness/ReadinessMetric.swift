//
//  ReadinessMetric.swift
//  StatsKit
//
//  Created by Findlay Wood on 10/11/2026.
//

import Foundation

/// What the readiness chart plots: readiness itself, or one of the four questions behind it.
///
/// **Everything is on readiness's own 0–1 scale** — a question's 1–5 answer over 5, which is how
/// readiness is made from them — so switching between them never rescales the chart, and a
/// question that pulls readiness down sits visibly below it.
enum ReadinessMetric: String, CaseIterable, Identifiable {
    case readiness, sleep, body, focus, mood

    var id: String { rawValue }

    var title: String {
        switch self {
        case .readiness: return "Readiness"
        case .sleep: return "Sleep"
        case .body: return "Body"
        case .focus: return "Focus"
        case .mood: return "Mood"
        }
    }

    func value(from day: ReadinessDay) -> Double? {
        switch self {
        case .readiness: return day.readiness
        case .sleep: return day.sleep.map { Double($0) / 5 }
        case .body: return day.body.map { Double($0) / 5 }
        case .focus: return day.focus.map { Double($0) / 5 }
        case .mood: return day.mood.map { Double($0) / 5 }
        }
    }

    /// "72%" for readiness, "3.6 / 5" for a question — each in the units it was answered in.
    func formatted(_ value: Double) -> String {
        switch self {
        case .readiness: return "\(Int((value * 100).rounded()))%"
        default: return String(format: "%.1f / 5", value * 5)
        }
    }
}
