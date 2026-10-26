//
//  OncePerDayAppOpenRecorder.swift
//  InTheGym
//
//  Created by Findlay Wood on 26/10/2026.
//  Copyright © 2026 FindlayWood. All rights reserved.
//

import Foundation

/// Lets an open through once per user per UTC day. The app becomes active
/// many times a day; the document only needs marking once, and every repeat
/// would be a Firestore write billed for nothing.
///
/// **Remembered only after the write succeeds**, so a failed one is tried
/// again on the next open rather than lost for the day. Offline, Firestore
/// queues the write and its completion waits for the network — until then
/// later opens try again, which is harmless: the write is idempotent.
///
/// Keyed by user id, so a second account signing in on the same phone the
/// same day is recorded too.
final class OncePerDayAppOpenRecorder: AppOpenRecorder {

    private let wrapped: AppOpenRecorder
    private let currentUserId: () -> String?
    private let defaults: UserDefaults
    private let now: () -> Date

    init(
        wrapping wrapped: AppOpenRecorder,
        currentUserId: @escaping () -> String?,
        defaults: UserDefaults = .standard,
        now: @escaping () -> Date = { .now }
    ) {
        self.wrapped = wrapped
        self.currentUserId = currentUserId
        self.defaults = defaults
        self.now = now
    }

    func recordOpen() async throws {
        guard let userId = currentUserId() else { return }
        let day = UserDayKey.day(for: now())
        let key = "lastAppOpenRecorded.\(userId)"
        guard defaults.string(forKey: key) != day else { return }

        try await wrapped.recordOpen()
        defaults.set(day, forKey: key)
    }
}
