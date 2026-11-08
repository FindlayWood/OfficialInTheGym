//
//  FirestoreScheduleUploader.swift
//  InTheGym
//
//  Created by Findlay Wood on 08/11/2026.
//  Copyright © 2026 FindlayWood. All rights reserved.
//

import FirebaseFirestore
import Foundation
import MyDayKit

/// Writes `Users/{userId}/Schedules/{id}`. This path only.
///
/// **A replace, never a merge.** `recurrence` and `item` are maps keyed by their
/// case, and a merge joins maps. Changing a schedule from weekly to every two
/// weeks would leave the document holding both keys, and it would then fail to
/// decode everywhere. A merge could also never clear `stoppedAt`.
final class FirestoreScheduleUploader: ScheduleUploading {

    private let userId: String

    init(userId: String) {
        self.userId = userId
    }

    func upload(_ schedule: Schedule) async throws {
        try await withCheckedThrowingContinuation { (continuation: CheckedContinuation<Void, Error>) in
            do {
                try Firestore.firestore()
                    .collection("Users/\(userId)/Schedules")
                    .document(schedule.id)
                    .setData(from: schedule) { error in
                        if let error {
                            continuation.resume(throwing: error)
                        } else {
                            continuation.resume()
                        }
                    }
            } catch {
                continuation.resume(throwing: error)
            }
        }
    }
}
