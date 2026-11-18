//
//  DiscoverKitRoutesTests.swift
//  DiscoverKitTests
//
//  Created by Findlay Wood on 12/10/2026.
//

import XCTest
@testable import DiscoverKit

final class DiscoverKitRoutesTests: XCTestCase {

    // Watching a clip is pro, from every way in — home, see-all, an exercise page, a profile's
    // clips grid — because they all push `.clipPlayer` through `navigate(to:)`.
    func test_requiresPro_deliversTrueForClipPlayer() {
        let sut = DiscoverKitRoutes.clipPlayer(clipCard)

        XCTAssertTrue(sut.requiresPro)
    }

    // Clips stay visible without pro — the thumbnails are what sell it. Gating the list as well as
    // the player would hide the very thing the paywall is asking them to pay to watch.
    func test_requiresPro_deliversFalseForEveryOtherRoute() {
        let routes: [DiscoverKitRoutes] = [
            .home, .allClips, .allWorkouts, .allExercises, .comments(.clip(id: "clip1")),
            .tag("legs"), .blockedUsers, .search
        ]

        for sut in routes {
            XCTAssertFalse(sut.requiresPro, "\(sut)")
        }
    }

    // A workout page is free, and is now also reached from a profile's Workouts section through
    // `showWorkout`. Gating it would put a paywall between someone and a workout their profile
    // lists as public.
    func test_requiresPro_deliversFalseForAWorkoutPage() {
        let sut = DiscoverKitRoutes.workoutDetail(workoutCard)

        XCTAssertFalse(sut.requiresPro)
    }

    // MARK: - Helpers

    private var workoutCard: DiscoverWorkoutCard {
        DiscoverWorkoutCard(
            templateId: "w1", title: "Saturday Upper", createdBy: "u1", exerciseCount: 5,
            createdAt: nil, isPublic: true
        )
    }

    private var clipCard: DiscoverClipCard {
        DiscoverClipCard(
            clipId: "clip1", exerciseId: "squat", exerciseName: "Squat", videoURL: nil, thumbnailURL: nil,
            durationSeconds: 12, createdBy: "u1", uploadedAt: nil, likeCount: 3
        )
    }
}
