//
//  ClipWatchRecorder.swift
//  DiscoverKit
//
//  Created by Findlay Wood on 30/09/2026.
//

import Foundation

/// Reports how a clip was watched, feeding the engagement counts on its card.
///
/// **The same signature as MyDayKit's `ViewClipRecorder`, on purpose.** The
/// composition root's existing `FirebaseFunctionsViewClipRecorder` conforms to
/// both, so a watch from DISCOVER and a watch from MyDay land in the one
/// `recordClipWatch` function by the one path — without DiscoverKit importing
/// MyDayKit.
public protocol ClipWatchRecorder {
    func recordClipWatch(
        clipID: String,
        watchedMoreThanThreeSeconds: Bool,
        watchedFullVideo: Bool,
        closePosition: Double,
        loopCount: Int
    )
}
