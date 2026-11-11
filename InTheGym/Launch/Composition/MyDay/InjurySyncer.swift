//
//  InjurySyncer.swift
//  InTheGym
//
//  Created by Findlay Wood on 10/11/2026.
//  Copyright © 2026 FindlayWood. All rights reserved.
//

import Foundation
import MyDayKit

/// Tries the remote write and, if it fails, queues the injury for
/// `InjurySyncService` to retry, `CustomExerciseSyncer`'s shape.
final class InjurySyncer: InjuryUploading {

    private let remote: InjuryUploading
    private let queue: InjuryUploading

    init(remote: InjuryUploading, queue: InjuryUploading) {
        self.remote = remote
        self.queue = queue
    }

    func upload(_ injury: Injury) async throws {
        do {
            try await remote.upload(injury)
        } catch {
            try await queue.upload(injury)
        }
    }
}
