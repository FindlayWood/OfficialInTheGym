//
//  JumpTaggingViewModel.swift
//  PerformanceKit
//
//  Created by Findlay Wood on 10/10/2026.
//
import Foundation

/// Tagging a recorded jump: one event at a time, in the order the test's tag
/// plan gives, with undo. It replaced `JumpMeasureViewModel`, which knew only a
/// take-off and a landing, held them in two fixed slots, and silently ignored a
/// tag in the wrong order.
///
/// **A tag must come after the previous one, and after zero** (`JumpTiming`).
/// One that does not is refused with a reason the screen can show, rather than
/// dropped without a word, which left the athlete tapping a button that did
/// nothing.
struct JumpTaggingViewModel {

    enum TagResult: Equatable {
        case accepted
        case rejected(String)
    }

    let plan: [JumpEvent]
    private(set) var times: [Double] = []

    init(plan: [JumpEvent]) {
        self.plan = plan
    }

    /// The event the next tag will mark, or nil when every event is tagged.
    var nextEvent: JumpEvent? {
        times.count < plan.count ? plan[times.count] : nil
    }

    var isComplete: Bool {
        nextEvent == nil
    }

    /// What the tag button reads: "Tag take-off (1 of 2)".
    var prompt: String? {
        guard let nextEvent else { return nil }
        return "Tag \(nextEvent.title) (\(times.count + 1) of \(plan.count))"
    }

    /// The measured jump, once every event is tagged.
    var attempt: JumpAttempt? {
        JumpTiming(plan: plan, times: times).map(JumpAttempt.init(timing:))
    }

    mutating func tag(at time: Double) -> TagResult {
        guard let nextEvent else { return .rejected("Every event is tagged. Undo to change one.") }
        guard time > 0 else { return .rejected("The first frame can't be tagged. Step forward a frame.") }
        guard JumpTiming.canTag(time, after: times) else {
            return .rejected("The \(nextEvent.title) has to come after the \(plan[times.count - 1].title).")
        }
        times.append(time)
        return .accepted
    }

    mutating func undo() {
        guard !times.isEmpty else { return }
        times.removeLast()
    }
}
