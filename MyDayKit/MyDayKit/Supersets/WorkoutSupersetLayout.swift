//
//  WorkoutSupersetLayout.swift
//  MyDayKit
//
//  Created by Findlay Wood on 18/11/2026.
//

import Foundation

/// How a workout's exercises read once supersets are taken into account: "1a, 1b, 2, 3a, 3b".
///
/// **The one definition of a superset and of its labels.** A superset is a run of two or more
/// *consecutive* exercises carrying the same `supersetId`. Labels are never stored: they are worked
/// out from the order every time they are drawn, so removing or unlinking an exercise cannot leave
/// a stale "3b" behind. The builder, MyDay's workout page, the session screen and DISCOVER's page
/// (through the composition root) all read this, and **none may re-derive it**.
///
/// An id that only one exercise carries, or the same id on two exercises with another between them,
/// is not a superset: each such exercise reads as its own number. Every template written before
/// supersets has no ids at all, and so reads as a plain numbered list.
public struct WorkoutSupersetLayout: Equatable, Sendable {

    /// Where an exercise sits in its group. `.single` is an exercise on its own.
    public enum Position: Equatable, Sendable {
        case single
        case first
        case middle
        case last

        /// Whether the exercise is in a superset at all.
        public var isInSuperset: Bool { self != .single }

        /// Whether the next exercise belongs to the same superset.
        public var continuesToNext: Bool { self == .first || self == .middle }

        /// Whether a set of this exercise is followed by rest. Inside a superset the exercises are
        /// done back to back, so only the last one rests; that rest is the whole round's.
        public var restsAfter: Bool { !continuesToNext }
    }

    public struct Entry: Equatable, Sendable {
        /// 1-based, counting a superset once.
        public let number: Int
        /// "a", "b", … inside a superset; `nil` on an exercise on its own.
        public let letter: String?
        public let position: Position

        /// "1a", "2".
        public var label: String { "\(number)\(letter ?? "")" }
    }

    /// One per exercise, in the order given.
    public let entries: [Entry]

    /// Whether any exercise is in a superset. Screens only show labels when this is true, so a
    /// workout without supersets looks exactly as it always did.
    public var hasSupersets: Bool { entries.contains { $0.position.isInSuperset } }

    public init(supersetIds: [String?]) {
        var entries: [Entry] = []
        var number = 0
        var index = 0
        while index < supersetIds.count {
            var end = index + 1
            if let id = supersetIds[index] {
                while end < supersetIds.count, supersetIds[end] == id { end += 1 }
            }
            number += 1
            let length = end - index
            if length == 1 {
                entries.append(Entry(number: number, letter: nil, position: .single))
            } else {
                for offset in 0..<length {
                    let position: Position = offset == 0 ? .first : (offset == length - 1 ? .last : .middle)
                    entries.append(Entry(number: number, letter: Self.letter(offset), position: position))
                }
            }
            index = end
        }
        self.entries = entries
    }

    public init(exercises: [WorkoutExerciseModel]) {
        self.init(supersetIds: exercises.map(\.supersetId))
    }

    /// "a" … "z", then "aa", "ab" — a superset of 27 is not a real workout, but it must not crash.
    private static func letter(_ offset: Int) -> String {
        let alphabet = Array("abcdefghijklmnopqrstuvwxyz")
        if offset < alphabet.count { return String(alphabet[offset]) }
        return letter(offset / alphabet.count - 1) + String(alphabet[offset % alphabet.count])
    }
}
