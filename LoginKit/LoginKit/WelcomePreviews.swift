//
//  WelcomePreviews.swift
//  LoginKit
//
//  Created by Findlay Wood on 18/10/2026.
//

import UIKit

/// Opens the example workout on the given stack. `signUp` is what its "Create Account" calls —
/// LoginKit owns signup, so the app hands the intent back rather than building the screen itself.
public typealias DemoWorkoutLauncher = (_ navigationController: UINavigationController, _ signUp: @escaping () -> Void) -> Void

/// Pushes a sample-data preview onto the given stack.
public typealias PreviewLauncher = (_ navigationController: UINavigationController) -> Void

/// What the welcome screen's feature cards open, supplied by the app.
///
/// LoginKit draws the cards and the app decides what they show: the example workout is MyDayKit's
/// session screen and the previews are StatsKit's and PerformanceKit's, none of which this
/// framework imports. **A card with no launcher is not drawn** — a card that opens nothing would
/// be a claim with no proof, which is the one thing the welcome screen exists not to make.
public struct WelcomePreviews {

    public var workout: DemoWorkoutLauncher?
    public var stats: PreviewLauncher?
    public var performance: PreviewLauncher?

    public init(workout: DemoWorkoutLauncher? = nil, stats: PreviewLauncher? = nil, performance: PreviewLauncher? = nil) {
        self.workout = workout
        self.stats = stats
        self.performance = performance
    }

    var features: [WelcomeFeature] {
        WelcomeFeature.allCases.filter { feature in
            switch feature {
            case .training: return workout != nil
            case .stats: return stats != nil
            case .performance: return performance != nil
            }
        }
    }
}
