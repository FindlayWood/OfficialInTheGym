//
//  JumpTiming.swift
//  PerformanceKit
//
//  Created by Findlay Wood on 10/10/2026.
//
import Foundation

/// The times between tagged events: each take-off → landing is a **flight**,
/// each landing → take-off a **ground contact**. Pure arithmetic over any tag
/// plan, so a drop jump or a run of repeated jumps needs no new maths.
///
/// Tags are valid only when there is one per event in the plan, **every time
/// is after the one before**, and the first is after zero. Zero counts as
/// untagged, which is why the very first frame of a video cannot be chosen,
/// the legacy rule.
struct JumpTiming: Equatable {

    let flights: [Double]
    let contacts: [Double]

    init?(plan: [JumpEvent], times: [Double]) {
        guard Self.isValid(plan: plan, times: times) else { return nil }
        var flights: [Double] = []
        var contacts: [Double] = []
        for index in 1..<plan.count {
            let interval = times[index] - times[index - 1]
            switch (plan[index - 1], plan[index]) {
            case (.takeOff, .landing): flights.append(interval)
            case (.landing, .takeOff): contacts.append(interval)
            default: break
            }
        }
        guard !flights.isEmpty else { return nil }
        self.flights = flights
        self.contacts = contacts
    }

    static func isValid(plan: [JumpEvent], times: [Double]) -> Bool {
        guard times.count == plan.count, let first = times.first, first > 0 else { return false }
        return zip(times, times.dropFirst()).allSatisfy { $0 < $1 }
    }

    /// Whether `time` may be tagged next after `times`: after zero, and after
    /// the last tag.
    static func canTag(_ time: Double, after times: [Double]) -> Bool {
        time > 0 && time > (times.last ?? 0)
    }
}
