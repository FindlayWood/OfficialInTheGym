//
//  ScheduleUploading.swift
//  MyDayKit
//
//  Created by Findlay Wood on 08/11/2026.
//

import Foundation

/// Writes one schedule somewhere. The same protocol at every layer of the pipeline, as
/// `CustomExerciseUploading` is: the local file, the Firestore path, the sync queue and the
/// decorators that compose them all conform, so the composition root can wrap one in another.
///
/// **Creating, editing and stopping are all this one call.** A schedule is written whole every
/// time, and stopping is a write with `stoppedAt` set, so there is no separate delete for the local
/// and remote copies to disagree over.
public protocol ScheduleUploading {
    func upload(_ schedule: Schedule) async throws
}
