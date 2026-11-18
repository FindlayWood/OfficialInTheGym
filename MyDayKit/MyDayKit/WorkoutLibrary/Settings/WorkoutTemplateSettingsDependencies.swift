//
//  WorkoutTemplateSettingsDependencies.swift
//  MyDayKit
//
//  Created by Findlay Wood on 13/11/2026.
//

import Foundation

/// What the workout page needs to change a workout's visibility and tags: the saver every template
/// goes through, and who is signed in. `nil` wherever it is taken leaves the page's `⋯` off.
///
/// **The saver must be the builder's**, `MyDayKitComposition`'s `WorkoutTemplateSaver`: device
/// first, then Firestore or the sync queue. Any other would leave the change on one side only.
/// Both paths are replaced by id, so an edit corrects the workout rather than adding a second
/// one, and the server moves its DISCOVER card and tag index to match.
public struct WorkoutTemplateSettingsDependencies {
    let saver: WorkoutTemplateUploading
    let userId: String

    public init(saver: WorkoutTemplateUploading, userId: String) {
        self.saver = saver
        self.userId = userId
    }
}
