//
//  FirestoreInjuryUploader.swift
//  InTheGym
//
//  Created by Findlay Wood on 10/11/2026.
//  Copyright © 2026 FindlayWood. All rights reserved.
//

import FirebaseFirestore
import Foundation
import MyDayKit

/// Writes `Users/{userId}/Injuries/{id}`. This path only.
///
/// **A replace, never a merge**, as `FirestoreScheduleUploader` is: a merge
/// could never clear `resolvedOn` once an injury was reopened, and it would keep
/// keys a later version had dropped. Check-ins from two devices are reconciled
/// on the device instead (`Injury.merged`), and `InjuryManager.load` writes the
/// merge back.
final class FirestoreInjuryUploader: InjuryUploading {

    private let userId: String

    init(userId: String) {
        self.userId = userId
    }

    func upload(_ injury: Injury) async throws {
        try await withCheckedThrowingContinuation { (continuation: CheckedContinuation<Void, Error>) in
            do {
                try Firestore.firestore()
                    .collection("Users/\(userId)/Injuries")
                    .document(injury.id)
                    .setData(from: injury) { error in
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
