//
//  WorkoutLibraryState+Template.swift
//  MyDayKit
//
//  Created by Findlay Wood on 11/11/2026.
//

import Foundation

extension WorkoutLibraryState {

    /// The library's copy of one workout, or `nil` when the library does not hold it, or has not
    /// loaded yet. Another tab only knows a workout by its id, so this is how it gets back to the
    /// template MyDay's screens take.
    func template(id: String) -> WorkoutTemplateModel? {
        guard case .loaded(let templates) = self else { return nil }
        return templates.first { $0.id == id }
    }
}
