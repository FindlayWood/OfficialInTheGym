//
//  TemplateDiscoverWorkoutDetailLoader.swift
//  InTheGym
//
//  Created by Findlay Wood on 02/10/2026.
//  Copyright © 2026 FindlayWood. All rights reserved.
//

import DiscoverKit
import Foundation

/// A workout page's contents: the template, read by id and mapped to
/// DiscoverKit's model.
struct TemplateDiscoverWorkoutDetailLoader: DiscoverWorkoutDetailLoader {

    let fetcher: WorkoutTemplateByIdFetching

    func detail(ofWorkout templateId: String) async throws -> DiscoverWorkoutDetail {
        try await fetcher.fetch(templateId: templateId).discoverDetail
    }
}
