//
//  WorkoutTemplateByIdFetching.swift
//  InTheGym
//
//  Created by Findlay Wood on 02/10/2026.
//  Copyright © 2026 FindlayWood. All rights reserved.
//

import Foundation
import MyDayKit

/// Reads one public workout template by id — what a DISCOVER workout page shows
/// and what saving a copy copies. One reader behind both, so the page and the
/// copy cannot read the template two different ways.
protocol WorkoutTemplateByIdFetching {
    func fetch(templateId: String) async throws -> WorkoutTemplateModel
}
