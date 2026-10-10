//
//  JumpTestKind.swift
//  PerformanceKit
//
//  Created by Findlay Wood on 10/10/2026.
//
import Foundation

/// A jump test the engine can run. Each one is a **tag plan** (the events the
/// athlete marks on the replay, in order, with what to call each and how to
/// spot it) and a number of attempts, and the engine does the rest: record,
/// tag, measure, best of the attempts. The screens are shared too, so a new
/// jump test is a new case here, not new screens.
///
/// - **CMJ** (countermovement jump): hands on hips, no arm swing. The
///   repeatable test, the one the weekly fatigue check uses, and the one
///   power is estimated from.
/// - **Vertical Jump**: arm swing allowed. The "how high can I go" number.
/// - **Drop jump**: step off a box, land, and rebound as fast and as high as
///   possible. Three tags: the landing off the box, the take-off, the landing.
///   Its result is **RSI**, not height (`headline`).
///
/// `rawValue` is what is stored as `kind` on a session document, so **a case
/// is never renamed**. `@frozen` because PerformanceKit builds with library
/// evolution.
@frozen
public enum JumpTestKind: String, Sendable, CaseIterable {
    case cmj
    case verticalJump
    case dropJump

    /// What a test's result is, and so what picks its best attempt.
    enum Headline {
        case height
        case reactiveStrength
    }

    var title: String {
        switch self {
        case .cmj: "CMJ"
        case .verticalJump: "Vertical Jump"
        case .dropJump: "Drop Jump"
        }
    }

    /// One line on what the test is, under its title.
    var summary: String {
        switch self {
        case .cmj: "Countermovement jump, hands on hips. Height and power."
        case .verticalJump: "Jump height with arm swing, measured on camera."
        case .dropJump: "Drop off a box and rebound. Reactive strength (RSI)."
        }
    }

    var tagPlan: [JumpEvent] {
        switch self {
        case .cmj, .verticalJump: [.takeOff, .landing]
        case .dropJump: [.landing, .takeOff, .landing]
        }
    }

    /// What the tag button calls each tag, by position in `tagPlan`. A drop
    /// jump has two landings, and "Tag landing (1 of 3)" would not say which.
    var tagTitles: [String] {
        switch self {
        case .cmj, .verticalJump: ["take-off", "landing"]
        case .dropJump: ["box landing", "take-off", "landing"]
        }
    }

    /// How to spot each tag, shown above the tag button.
    var tagHints: [String] {
        switch self {
        case .cmj, .verticalJump:
            ["Step to the last frame your feet are on the ground.",
             "Step to the first frame your feet are back on the ground."]
        case .dropJump:
            ["Step to the first frame your feet touch the ground after leaving the box.",
             "Step to the last frame your feet are on the ground before you rebound.",
             "Step to the first frame your feet are back on the ground."]
        }
    }

    /// A test is the best of this many attempts. One jump is too noisy to
    /// track.
    var attempts: Int { 3 }

    var headline: Headline {
        switch self {
        case .cmj, .verticalJump: .height
        case .dropJump: .reactiveStrength
        }
    }

    /// Whether peak power is estimated from this test's height. Only CMJ: the
    /// estimate (`JumpPower`) was fitted to jumps without arm swing or a drop.
    var estimatesPower: Bool {
        self == .cmj
    }

    /// Whether the test is done off a box whose height is recorded with it.
    var usesBoxHeight: Bool {
        self == .dropJump
    }

    /// How to do one jump, the step the instructions add to the shared ones.
    var technique: String {
        switch self {
        case .cmj: "Stand tall with your hands on your hips. Dip and jump straight up as high as you can, keeping your hands on your hips and your legs straight in the air."
        case .verticalJump: "Stand tall, swing your arms, and jump straight up as high as you can. Land on the spot."
        case .dropJump: "Stand on the box, hands on hips. Step off, don't jump off, and the moment you land, jump straight back up as high and as fast as you can. Spend as little time on the ground as possible."
        }
    }

    /// The instruction steps for tagging, one per tag.
    var tagSteps: [String] {
        switch self {
        case .cmj, .verticalJump:
            ["On the replay, step frame by frame. Tag take-off on the last frame your feet are on the ground.",
             "Tag landing on the first frame your feet are back on the ground. Undo if you got one wrong."]
        case .dropJump:
            ["On the replay, step frame by frame. Tag the box landing on the first frame your feet touch the ground.",
             "Tag take-off on the last frame your feet are on the ground before the rebound.",
             "Tag the landing on the first frame your feet are back down. Undo if you got one wrong."]
        }
    }
}
