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
/// - **Single-leg CMJ**: a CMJ on one leg, attempts on each (`sides`). Its
///   result is each leg's best and the asymmetry between them (`LimbSymmetry`).
/// - **Repeated jumps** (10/5): ten hops in a row, twenty tags. Its result is
///   the mean RSI of the best five rebounds (`JumpAttempt`).
///
/// `rawValue` is what is stored as `kind` on a session document, so **a case
/// is never renamed**. `@frozen` because PerformanceKit builds with library
/// evolution.
@frozen
public enum JumpTestKind: String, Sendable, CaseIterable {
    case cmj
    case verticalJump
    case dropJump
    case singleLegCMJ
    case repeatedJumps

    /// Hops in one repeated-jumps attempt, and how many of the best count.
    static let hopCount = 10
    var bestHops: Int { 5 }

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
        case .singleLegCMJ: "Single-Leg CMJ"
        case .repeatedJumps: "Repeated Jumps"
        }
    }

    /// One line on what the test is, under its title.
    var summary: String {
        switch self {
        case .cmj: "Countermovement jump, hands on hips. Height and power."
        case .verticalJump: "Jump height with arm swing, measured on camera."
        case .dropJump: "Drop off a box and rebound. Reactive strength (RSI)."
        case .singleLegCMJ: "A CMJ on each leg. Left against right."
        case .repeatedJumps: "Ten hops in a row. RSI of your best five (10/5)."
        }
    }

    var tagPlan: [JumpEvent] {
        switch self {
        case .cmj, .verticalJump, .singleLegCMJ: [.takeOff, .landing]
        case .dropJump: [.landing, .takeOff, .landing]
        case .repeatedJumps: [.takeOff] + (1..<Self.hopCount).flatMap { _ in [JumpEvent.landing, .takeOff] } + [.landing]
        }
    }

    /// What the tag button calls each tag, by position in `tagPlan`. A drop
    /// jump has two landings, and "Tag landing (1 of 3)" would not say which.
    var tagTitles: [String] {
        switch self {
        case .cmj, .verticalJump, .singleLegCMJ: ["take-off", "landing"]
        case .dropJump: ["box landing", "take-off", "landing"]
        case .repeatedJumps: numberedHops.map { "\($0.event == .takeOff ? "take-off" : "landing") \($0.hop)" }
        }
    }

    /// How to spot each tag, shown above the tag button.
    var tagHints: [String] {
        switch self {
        case .cmj, .verticalJump, .singleLegCMJ:
            ["Step to the last frame your feet are on the ground.",
             "Step to the first frame your feet are back on the ground."]
        case .repeatedJumps:
            numberedHops.map {
                $0.event == .takeOff
                    ? "Step to the last frame your feet are on the ground before hop \($0.hop)."
                    : "Step to the first frame your feet are back down after hop \($0.hop)."
            }
        case .dropJump:
            ["Step to the first frame your feet touch the ground after leaving the box.",
             "Step to the last frame your feet are on the ground before you rebound.",
             "Step to the first frame your feet are back on the ground."]
        }
    }

    /// A test is the best of this many attempts. One jump is too noisy to
    /// track.
    /// For a single-leg test, this many on each leg. Repeated jumps take two:
    /// each is ten hops and twenty tags.
    var attempts: Int {
        self == .repeatedJumps ? 2 : 3
    }

    /// The legs a test is done on, one at a time. Empty for a two-legged test.
    var sides: [JumpSide] {
        self == .singleLegCMJ ? [.left, .right] : []
    }

    var headline: Headline {
        switch self {
        case .cmj, .verticalJump, .singleLegCMJ: .height
        case .dropJump, .repeatedJumps: .reactiveStrength
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
        case .singleLegCMJ: "Stand on one leg with your hands on your hips. Dip and jump as high as you can, landing on the same leg. Do your attempts on one leg, then the other."
        case .repeatedJumps: "Hands on hips. Hop ten times in a row on the spot, as high as you can with as little time on the ground as possible, legs stiff."
        }
    }

    /// The instruction steps for tagging, one per tag.
    var tagSteps: [String] {
        switch self {
        case .cmj, .verticalJump, .singleLegCMJ:
            ["On the replay, step frame by frame. Tag take-off on the last frame your feet are on the ground.",
             "Tag landing on the first frame your feet are back on the ground. Undo if you got one wrong."]
        case .repeatedJumps:
            ["On the replay, step frame by frame and tag every take-off and every landing, all ten hops: twenty tags.",
             "The button names each one in turn. Undo if you got one wrong."]
        case .dropJump:
            ["On the replay, step frame by frame. Tag the box landing on the first frame your feet touch the ground.",
             "Tag take-off on the last frame your feet are on the ground before the rebound.",
             "Tag the landing on the first frame your feet are back down. Undo if you got one wrong."]
        }
    }

    /// Each tag of a repeated-jumps plan with the hop it belongs to: a
    /// take-off starts hop n, the landing after it ends hop n.
    private var numberedHops: [(event: JumpEvent, hop: Int)] {
        var hop = 0
        return tagPlan.map { event in
            if event == .takeOff { hop += 1 }
            return (event, hop)
        }
    }
}
