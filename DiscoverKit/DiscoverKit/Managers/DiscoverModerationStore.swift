//
//  DiscoverModerationStore.swift
//  DiscoverKit
//
//  Created by Findlay Wood on 30/09/2026.
//

import Combine
import Foundation

/// What the signed-in user has chosen not to see: the users they blocked and
/// the things they reported. One store for the whole DISCOVER flow, built by
/// the router and handed to every screen that lists something.
///
/// **Filtering is on the device, by design.** A block is private and one-way,
/// so no other user's query can take it into account — it can only be applied
/// where the user is looking. A report hides the thing from its reporter at
/// once, before (and whether or not) three people agree and the server hides
/// it for everyone.
///
/// Both actions show immediately and are put back if the write fails.
@MainActor
public final class DiscoverModerationStore: ObservableObject {

    @Published private(set) var blockedUserIds: Set<String> = []
    @Published private(set) var reportedTargets: Set<DiscoverReportTarget> = []

    private let blockedLoader: BlockedUsersLoader
    private let reportsLoader: MyReportsLoader
    private let reportWriter: ReportWriter
    private let blockWriter: BlockedUsersWriter
    private var hasLoaded = false

    public init(
        blockedLoader: BlockedUsersLoader,
        reportsLoader: MyReportsLoader,
        reportWriter: ReportWriter,
        blockWriter: BlockedUsersWriter
    ) {
        self.blockedLoader = blockedLoader
        self.reportsLoader = reportsLoader
        self.reportWriter = reportWriter
        self.blockWriter = blockWriter
    }

    /// Loads once per session. A failure leaves both sets empty and is retried
    /// on the next call — showing too much beats blocking the screen.
    func loadIfNeeded() async {
        guard !hasLoaded else { return }
        async let blocked = try? blockedLoader.blockedUserIds()
        async let reported = try? reportsLoader.reportedTargets()
        let (loadedBlocked, loadedReported) = await (blocked, reported)
        if let loadedBlocked { blockedUserIds.formUnion(loadedBlocked) }
        if let loadedReported { reportedTargets.formUnion(loadedReported) }
        hasLoaded = loadedBlocked != nil && loadedReported != nil
    }

    // MARK: - Actions

    /// Reports `target`, hiding it for this user straight away.
    @discardableResult
    func report(_ target: DiscoverReportTarget, reason: DiscoverReportReason) async -> Bool {
        guard !reportedTargets.contains(target) else { return true }
        reportedTargets.insert(target)
        do {
            try await reportWriter.report(target, reason: reason)
            return true
        } catch {
            print("❌ Report failed: \(error)")
            reportedTargets.remove(target)
            return false
        }
    }

    @discardableResult
    func setBlocked(_ blocked: Bool, userId: String) async -> Bool {
        let previous = blockedUserIds
        if blocked {
            blockedUserIds.insert(userId)
        } else {
            blockedUserIds.remove(userId)
        }
        do {
            try await blockWriter.setBlocked(blocked, userId: userId)
            return true
        } catch {
            print("❌ Block failed: \(error)")
            blockedUserIds = previous
            return false
        }
    }

    // MARK: - Filtering

    func isBlocked(_ userId: String?) -> Bool {
        userId.map(blockedUserIds.contains) ?? false
    }

    func hides(_ comment: DiscoverComment, on subject: DiscoverSubject) -> Bool {
        isBlocked(comment.authorId) || reportedTargets.contains(.comment(commentId: comment.id, subject: subject))
    }

    func hides(_ clip: DiscoverClipCard) -> Bool {
        isBlocked(clip.createdBy) || reportedTargets.contains(.clip(id: clip.clipId))
    }

    func hides(_ workout: DiscoverWorkoutCard) -> Bool {
        isBlocked(workout.createdBy) || reportedTargets.contains(.workout(id: workout.templateId))
    }

    func hides(tag: String) -> Bool {
        reportedTargets.contains(.tag(tag))
    }
}
