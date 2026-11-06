//
//  MyDayThenSportSessionSaver.swift
//  InTheGym
//
//  Created by Findlay Wood on 05/11/2026.
//  Copyright © 2026 FindlayWood. All rights reserved.
//

import Foundation
import MyDayKit

/// Puts a sport session in both of its homes by composing their writers. **Knows no paths** —
/// it only decides that both happen, and in what order.
///
/// **The day first.** The day saver writes the phone's day file and then the day document; the
/// day file is what MyDay reads and is the copy that survives being offline. If the day write
/// throws, the session document is not written either, so the separate document never holds a
/// session the day does not. The reverse gap — the day written, the session document not — is
/// the accepted one: the session is still in the day file and the document can be rebuilt from
/// it, exactly as for `CompletedWorkoutSession`.
final class MyDayThenSportSessionSaver: MyDayAndSportSessionSaver {

    private let day: MyDaySaver
    private let session: SportSessionSaver
    private let deleter: SportSessionDeleter

    init(day: MyDaySaver, session: SportSessionSaver, deleter: SportSessionDeleter) {
        self.day = day
        self.session = session
        self.deleter = deleter
    }

    func save(day updatedDay: MyDayFullDayModel, adding sportSession: SportSessionEntry) async throws {
        try await day.save(data: updatedDay)
        try await session.save(sportSession)
    }

    func save(day updatedDay: MyDayFullDayModel, removing sessionId: String) async throws {
        try await day.save(data: updatedDay)
        try await deleter.delete(sessionId: sessionId)
    }
}
