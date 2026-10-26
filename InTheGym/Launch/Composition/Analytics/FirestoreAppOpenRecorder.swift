//
//  FirestoreAppOpenRecorder.swift
//  InTheGym
//
//  Created by Findlay Wood on 26/10/2026.
//  Copyright © 2026 FindlayWood. All rights reserved.
//

import Foundation

/// Marks today's `UserDays` document opened. One path, one write — whether it
/// is worth making is `OncePerDayAppOpenRecorder`'s decision, not this one's.
///
/// **A merge, never a replace.** The document may already hold the server's
/// figures for the day; `upload(dataPoints:)` merges, so they survive, and
/// the rule would refuse a write that removed them anyway.
///
/// Signed out, it does nothing.
struct FirestoreAppOpenRecorder: AppOpenRecorder {

    var firestoreService: FirestoreService = FirestoreManager.shared
    let currentUserId: () -> String?
    var now: () -> Date = { .now }

    func recordOpen() async throws {
        guard let userId = currentUserId() else { return }
        let day = UserDayKey.day(for: now())
        let model = UserDayOpenedModel(userId: userId, date: day, openedApp: true)
        try await firestoreService.upload(dataPoints: [UserDayKey.path(userId: userId, day: day): model])
    }
}
