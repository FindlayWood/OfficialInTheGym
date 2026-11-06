//
//  SportSessionSaver.swift
//  MyDayKit
//
//  Created by Findlay Wood on 05/11/2026.
//

import Foundation

/// Writes a sport session as a document of its own — the copy stats and a future sport history
/// read, so that "what sport has this user played" does not mean reading every day document.
///
/// **Knows exactly one destination.** The day the session is embedded in is written by the day's
/// own `MyDaySaver`; the two are composed by a `MyDayAndSportSessionSaver` that knows no paths.
/// Resolving the signed-in user is the composition root's job, as for every other saver.
public protocol SportSessionSaver {
    func save(_ session: SportSessionEntry) async throws
}

struct PreviewSportSessionSaver: SportSessionSaver {
    func save(_ session: SportSessionEntry) async throws {
        print("Saving sport session: \(session.id)")
    }
}
