//
//  WorkoutTemplateSyncer.swift
//  InTheGym
//
//  Created by Findlay Wood on 04/06/2026.
//  Copyright © 2026 FindlayWood. All rights reserved.
//

import Foundation
import MyDayKit

final class WorkoutTemplateSyncer: WorkoutTemplateUploading {

    private let remote: WorkoutTemplateUploading
    private let queue: WorkoutTemplateUploading

    init(remote: WorkoutTemplateUploading, queue: WorkoutTemplateUploading) {
        self.remote = remote
        self.queue = queue
    }

    func upload(_ template: WorkoutTemplateModel) async throws {
        do {
            try await remote.upload(template)
        } catch {
            // Remote failed — persist to sync queue for later retry
            try await queue.upload(template)
        }
    }
}
