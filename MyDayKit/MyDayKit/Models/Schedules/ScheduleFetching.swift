//
//  ScheduleFetching.swift
//  MyDayKit
//
//  Created by Findlay Wood on 08/11/2026.
//

import Foundation

/// Reads the signed-in user's schedules from one store, the local files or their Firestore copy.
/// `ScheduleManager` reads both and merges them, the read half of `ScheduleUploading`'s local-first
/// write.
public protocol ScheduleFetching {
    func fetchAll() async throws -> [Schedule]
}
