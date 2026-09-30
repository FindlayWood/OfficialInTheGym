//
//  ClipWatchRecorderSpy.swift
//  DiscoverKitTests
//
//  Created by Findlay Wood on 30/09/2026.
//

import Foundation
@testable import DiscoverKit

/// Records every watch reported. Never asserts — the test does.
final class ClipWatchRecorderSpy: ClipWatchRecorder, @unchecked Sendable {

    struct Watch: Equatable {
        let clipID: String
        let watchedMoreThanThreeSeconds: Bool
        let watchedFullVideo: Bool
        let closePosition: Double
        let loopCount: Int
    }

    private(set) var receivedWatches: [Watch] = []

    func recordClipWatch(clipID: String, watchedMoreThanThreeSeconds: Bool, watchedFullVideo: Bool, closePosition: Double, loopCount: Int) {
        receivedWatches.append(Watch(
            clipID: clipID,
            watchedMoreThanThreeSeconds: watchedMoreThanThreeSeconds,
            watchedFullVideo: watchedFullVideo,
            closePosition: closePosition,
            loopCount: loopCount
        ))
    }
}
