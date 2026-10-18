//
//  WorkoutSessionNotice.swift
//  MyDayKit
//
//  Created by Findlay Wood on 18/10/2026.
//

import Foundation

/// What `WorkoutSessionNoticeBanner` says: a line about what to do next, and
/// an optional quieter one under it. The screen asks for it on every render,
/// so a notice can follow the session as it moves — the demo's hints do.
struct WorkoutSessionNotice: Equatable {
    let text: String
    var detail: String? = nil
}
