//
//  ProfileReporter.swift
//  ProfileKit
//
//  Created by Findlay Wood on 04/10/2026.
//
import Foundation

/// Reports someone's profile (its name, bio or photo). Three distinct
/// reporters, or one admin, hide it (`PROFILE_PLAN.md` step 9), the same rule
/// as every DISCOVER report. One report per user per profile: a second is
/// refused by the rules, and the screen treats having reported as final.
public protocol ProfileReporter {
    func report(_ userId: String, reason: ProfileReportReason) async throws
}
