//
//  LibraryWorkoutCopyChecker.swift
//  InTheGym
//
//  Created by Findlay Wood on 02/10/2026.
//  Copyright © 2026 FindlayWood. All rights reserved.
//

import DiscoverKit
import Foundation
import MyDayKit

/// Whether the user's library already holds a copy of a workout, by
/// `copiedFrom`. Reads the local store — the copy is written there first, so a
/// copy saved moments ago and not yet synced still counts. A failed read is
/// "not saved": offering Save again is better than hiding it.
struct LibraryWorkoutCopyChecker: SavedWorkoutCopyChecker {

    let local: WorkoutTemplateFetching

    func hasSavedCopy(ofWorkout templateId: String) async -> Bool {
        let templates = (try? await local.fetchAll()) ?? []
        return templates.contains { $0.copiedFrom == templateId }
    }
}
