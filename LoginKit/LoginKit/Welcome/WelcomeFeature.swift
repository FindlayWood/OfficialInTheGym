//
//  WelcomeFeature.swift
//  LoginKit
//
//  Created by Findlay Wood on 18/10/2026.
//

import Foundation

/// The three things the welcome screen says the app does, each a card that can be tried.
///
/// **Every line has a proof one tap away.** Someone who has never heard of the app needs to know
/// what it is before Sign Up means anything, but four slides of marketing before the buttons is the
/// "step that only tells" account creation cut. So the welcome screen explains in three lines and
/// each line opens the real thing — the example workout, or the pro tabs on sample data. The pro
/// two say so on the card, so nobody signs up expecting them free.
enum WelcomeFeature: CaseIterable, Identifiable {
    case training
    case stats
    case performance

    var id: Self { self }

    var title: String {
        switch self {
        case .training: return "Log your training"
        case .stats: return "See it add up"
        case .performance: return "Test your readiness"
        }
    }

    var subtitle: String {
        switch self {
        case .training: return "Plan workouts and log every set as you go."
        case .stats: return "Weekly volume, streaks and training load."
        case .performance: return "Jump tests and a weekly fatigue check."
        }
    }

    /// The line under the tagline while this card's scene plays, so the header and the card it is
    /// pointing at say the same thing.
    var headline: String {
        switch self {
        case .training: return "Log every set."
        case .stats: return "See it add up."
        case .performance: return "Know when you're fresh."
        }
    }

    var actionTitle: String {
        switch self {
        case .training: return "Try a workout"
        case .stats, .performance: return "Preview"
        }
    }

    var isPro: Bool {
        self != .training
    }
}
