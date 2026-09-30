//
//  DiscoverClipPlayerViewModel.swift
//  DiscoverKit
//
//  Created by Findlay Wood on 30/09/2026.
//

import Combine
import Foundation

/// A clip being watched: its like, and the watch it reports when the screen
/// goes.
///
/// **One watch is recorded per visit, on leaving** — how far through it was
/// closed, whether it got past three seconds, whether it played to the end,
/// how many times it looped. That is what `recordClipWatch` takes, and the
/// clip card's view counts come from it. `hasRecorded` stops a second report
/// if the screen disappears twice.
@MainActor
final class DiscoverClipPlayerViewModel: ObservableObject {

    @Published private(set) var isLiked = false
    @Published private(set) var likeCount: Int
    @Published private(set) var didFailToLike = false

    let card: DiscoverClipCard

    private let likeLoader: LikeLoader
    private let likeWriter: LikeWriter
    private let recorder: ClipWatchRecorder

    private var startedAt: Date?
    private var position: Double = 0
    private var loops = 0
    private var hasRecorded = false

    init(card: DiscoverClipCard, likeLoader: LikeLoader, likeWriter: LikeWriter, recorder: ClipWatchRecorder) {
        self.card = card
        self.likeCount = card.likeCount ?? 0
        self.likeLoader = likeLoader
        self.likeWriter = likeWriter
        self.recorder = recorder
    }

    func load() async {
        startedAt = startedAt ?? Date()
        let target = DiscoverLikeTarget.clip(id: card.clipId)
        if let liked = try? await likeLoader.likedTargets(among: [target]) {
            isLiked = liked.contains(target)
        }
    }

    func toggleLike() async {
        let liked = !isLiked
        setLikeLocally(liked)
        didFailToLike = false
        do {
            try await likeWriter.setLiked(liked, for: .clip(id: card.clipId))
        } catch {
            print("❌ Clip like failed: \(error)")
            setLikeLocally(!liked)
            didFailToLike = true
        }
    }

    private func setLikeLocally(_ liked: Bool) {
        isLiked = liked
        likeCount = max(0, likeCount + (liked ? 1 : -1))
    }

    // MARK: - Watch

    func progressed(to position: Double) {
        self.position = position
    }

    func looped(_ count: Int) {
        loops = count
    }

    func finishWatching(now: Date = Date()) {
        guard !hasRecorded, let startedAt else { return }
        hasRecorded = true
        recorder.recordClipWatch(
            clipID: card.clipId,
            watchedMoreThanThreeSeconds: now.timeIntervalSince(startedAt) >= 3,
            watchedFullVideo: loops > 0,
            closePosition: min(max(position, 0), 1),
            loopCount: loops
        )
    }
}
