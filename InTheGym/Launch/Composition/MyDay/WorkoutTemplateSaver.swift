//
//  WorkoutTemplateSaver.swift
//  InTheGym
//
//  Created by Findlay Wood on 04/06/2026.
//  Copyright © 2026 FindlayWood. All rights reserved.
//

import Foundation
import MyDayKit

final class WorkoutTemplateSaver: WorkoutTemplateUploading {

    private let local: WorkoutTemplateUploading
    private let remote: WorkoutTemplateUploading

    init(local: WorkoutTemplateUploading, remote: WorkoutTemplateUploading) {
        self.local = local
        self.remote = remote
    }

    func upload(_ template: WorkoutTemplateModel) async throws {
        // 1. Write local — must succeed, throws to caller on failure
        try await local.upload(template)

        // 2. Write remote in background — caller is already unblocked
        Task.detached(priority: .background) { [remote] in
            try? await remote.upload(template)
        }
    }
}
