//
//  WorkoutTemplateFetching.swift
//  MyDayKit
//
//  Created by Findlay Wood on 04/06/2026.
//

import Foundation

public protocol WorkoutTemplateFetching {
    func fetchAll() async throws -> [WorkoutTemplateModel]
}

struct PreviewWorkoutTemplateFetching: WorkoutTemplateFetching {
    
    func fetchAll() async throws -> [WorkoutTemplateModel] {
        return []
    }
}
