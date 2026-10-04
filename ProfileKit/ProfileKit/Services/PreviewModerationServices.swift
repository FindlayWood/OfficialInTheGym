//
//  PreviewModerationServices.swift
//  ProfileKit
//
//  Created by Findlay Wood on 04/10/2026.
//
import Foundation

/// Preview conformer for reporting and blocking: nobody blocked, and every
/// write succeeds.
public final class PreviewModerationServices: ProfileReporter, ProfileBlocker, ProfileBlockStatusLoader, @unchecked Sendable {
    public init() {}

    public func report(_ userId: String, reason: ProfileReportReason) async throws {}

    public func setBlocked(_ blocked: Bool, userId: String) async throws {}

    public func hasBlocked(_ userId: String) async throws -> Bool { false }
}
