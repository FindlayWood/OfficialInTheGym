//
//  MyDayAndSportSessionSaver.swift
//  MyDayKit
//
//  Created by Findlay Wood on 05/11/2026.
//

import Foundation

/// Puts a sport session in both of its homes: the day it was played on, and its own document.
///
/// **This is the composed writer, never a writer itself.** The implementation is a decorator
/// over a `MyDaySaver` (the day) and a `SportSessionSaver` / `SportSessionDeleter` (the
/// session's document) that knows no paths at all — it only decides that both happen, the day
/// first. The day file is the local, authoritative copy, so it is never held back by the remote
/// document; a session document that fails can be rebuilt from the day.
///
/// `MyDayAndStatSaver` is the same shape for an exercise and its raw log.
public protocol MyDayAndSportSessionSaver {
    func save(day: MyDayFullDayModel, adding session: SportSessionEntry) async throws
    func save(day: MyDayFullDayModel, removing sessionId: String) async throws
}

struct PreviewMyDayAndSportSessionSaver: MyDayAndSportSessionSaver {
    func save(day: MyDayFullDayModel, adding session: SportSessionEntry) async throws {
        print("Saving day \(day.id) with sport session: \(session.id)")
    }

    func save(day: MyDayFullDayModel, removing sessionId: String) async throws {
        print("Saving day \(day.id) without sport session: \(sessionId)")
    }
}
