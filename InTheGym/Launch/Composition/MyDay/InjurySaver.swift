//
//  InjurySaver.swift
//  InTheGym
//
//  Created by Findlay Wood on 10/11/2026.
//  Copyright © 2026 FindlayWood. All rights reserved.
//

import Foundation
import MyDayKit

/// The writer MyDayKit is handed: local first, then remote in the background,
/// `CustomExerciseSaver`'s shape.
///
/// **Only the local write can fail the save.** Once the file is on disk the
/// injury exists and shows on MyDay; the remote copy is the syncer's problem,
/// which queues rather than loses it.
final class InjurySaver: InjuryUploading {

    private let local: InjuryUploading
    private let remote: InjuryUploading

    init(local: InjuryUploading, remote: InjuryUploading) {
        self.local = local
        self.remote = remote
    }

    func upload(_ injury: Injury) async throws {
        try await local.upload(injury)

        Task.detached(priority: .background) { [remote] in
            try? await remote.upload(injury)
        }
    }
}
