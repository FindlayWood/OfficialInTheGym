//
//  WorkoutTemplateFetcherSpy.swift
//  MyDayKitTests
//
//  Created by Findlay Wood on 09/11/2026.
//

import Foundation
@testable import MyDayKit

final class WorkoutTemplateFetcherSpy: WorkoutTemplateFetching {

    private(set) var fetchCount = 0
    private let templates: [WorkoutTemplateModel]

    init(_ templates: [WorkoutTemplateModel] = []) {
        self.templates = templates
    }

    func fetchAll() async throws -> [WorkoutTemplateModel] {
        fetchCount += 1
        return templates
    }
}
