//
//  PreviewModerationLoaders.swift
//  DiscoverKit
//
//  Created by Findlay Wood on 30/09/2026.
//

import Foundation

/// Preview conformer for every moderation read and write: nothing blocked,
/// nothing reported, and every action accepted.
public final class PreviewModeration: BlockedUsersLoader, MyReportsLoader, ReportWriter, BlockedUsersWriter, @unchecked Sendable {
    public init() {}

    public func blockedUserIds() async throws -> Set<String> { [] }

    public func reportedTargets() async throws -> Set<DiscoverReportTarget> { [] }

    public func report(_ target: DiscoverReportTarget, reason: DiscoverReportReason) async throws {}

    public func setBlocked(_ blocked: Bool, userId: String) async throws {}

    /// A store over this conformer, for previews.
    @MainActor
    public static func store() -> DiscoverModerationStore {
        let moderation = PreviewModeration()
        return DiscoverModerationStore(
            blockedLoader: moderation,
            reportsLoader: moderation,
            reportWriter: moderation,
            blockWriter: moderation
        )
    }
}
