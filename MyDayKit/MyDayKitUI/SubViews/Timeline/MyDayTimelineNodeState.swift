//
//  MyDayTimelineNodeState.swift
//  MyDayKit
//
//  Created by Findlay Wood on 18/10/2026.
//

import Foundation

/// How a step's node on the MyDay timeline is drawn. Four states, because the screen asks four
/// different things of a step: it is done, it can be done now, it cannot be done yet, or the day
/// is over and it was never done.
///
/// `.unavailable` exists for one case — rating a day with nothing trained on it. The step is
/// drawn rather than hidden so the user knows it is coming; dimmed so it does not read as
/// something to do now.
enum MyDayTimelineNodeState {
    /// Recorded. A filled node in the step's colour.
    case done
    /// Today, and can be done now. An outlined node.
    case pending
    /// Today, but not yet possible. An outlined node, dimmed.
    case unavailable
    /// A past day on which it was never done. A faint filled node, no colour.
    case missing
}
