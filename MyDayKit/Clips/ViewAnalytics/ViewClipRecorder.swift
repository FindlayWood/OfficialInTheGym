//
//  ViewClipRecorder.swift
//  MyDayKit
//
//  Created by Findlay Wood on 28/02/2026.
//

import Foundation

public protocol ViewClipRecorder {
    func recordClipWatch(
        clipID: String,
        watchedMoreThanThreeSeconds: Bool,
        watchedFullVideo: Bool,
        closePosition: Double,
        loopCount: Int
    )
}
