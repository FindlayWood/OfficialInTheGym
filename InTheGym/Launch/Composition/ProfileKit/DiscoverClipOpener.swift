//
//  DiscoverClipOpener.swift
//  InTheGym
//
//  Created by Findlay Wood on 04/10/2026.
//  Copyright © 2026 FindlayWood. All rights reserved.
//
import DiscoverKit
import ProfileKit
import UIKit

/// Opens a profile's clip in DISCOVER's clip player (likes, comments,
/// report), pushed onto the profile's own navigation stack by a DiscoverKit
/// router built there (`PROFILE_PLAN.md` step 8).
///
/// **The router is built lazily, on the first tap.** `DiscoverKitComposition`
/// builds a ProfileKit router for its author links, and `ProfileKitComposition`
/// builds one of these, so building eagerly would recurse forever. It holds
/// the navigation controller weakly, because the navigation controller
/// (through its screens' router) holds it.
///
/// A `ProfileClip` carries every field of the card, so it maps straight to a
/// `DiscoverClipCard` with no second read. Save to Library is not offered from
/// a workout reached this way (`workoutLibrary: nil`). Only the player is the
/// point.
final class DiscoverClipOpener {

    private weak var navigationController: UINavigationController?
    private let purchaseManager: PurchaseManager
    private var router: DiscoverKitRouter?

    init(navigationController: UINavigationController, purchaseManager: PurchaseManager) {
        self.navigationController = navigationController
        self.purchaseManager = purchaseManager
    }

    func open(_ clip: ProfileClip) {
        MainActor.assumeIsolated {
            guard let navigationController else { return }
            let router = self.router ?? DiscoverKitComposition().makeRouter(
                navigationController,
                workoutLibrary: nil,
                purchaseManager: purchaseManager
            )
            self.router = router
            router.showClip(DiscoverClipCard(
                clipId: clip.clipId,
                exerciseId: clip.exerciseId,
                exerciseName: clip.exerciseName,
                videoURL: clip.videoURL,
                thumbnailURL: clip.thumbnailURL,
                durationSeconds: clip.durationSeconds,
                createdBy: clip.createdBy,
                uploadedAt: clip.uploadedAt,
                likeCount: clip.likeCount,
                commentCount: clip.commentCount,
                viewCount: clip.viewCount
            ))
        }
    }
}
