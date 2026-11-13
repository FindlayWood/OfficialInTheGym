//
//  WorkoutTemplateSettingsEditor.swift
//  MyDayKit
//
//  Created by Findlay Wood on 13/11/2026.
//

import Combine
import Foundation

/// A saved workout's visibility and tags, changed from its page (`PROFILE_WORKOUTS_PLAN.md`,
/// *Workout settings*). Until now both were set once, in the builder, and nothing could change
/// them after.
///
/// **The sheet edits a draft, and closing it saves.** Values apply as the user changes them, as on
/// every MyDay sheet, and Done only dismisses. Saving on every toggle instead would write the
/// workout to disk and Firestore, and re-run the server's card and tag triggers, once per flip.
/// Closing with nothing changed writes nothing.
///
/// The save goes through the builder's saver and then into MyDay's library manager, where the
/// later `updatedAt` wins, so MyDay's library and PROFILE's All workouts show the change at once.
/// A failed save puts the draft back to what is stored and says so on the page. Only the device
/// write can fail here: a failed Firestore write is queued and retried by the sync service.
@MainActor
final class WorkoutTemplateSettingsEditor: ObservableObject {

    // MARK: - Dependencies

    private let saver: WorkoutTemplateUploading
    private let libraryManager: WorkoutLibraryManager
    private let now: () -> Date

    // MARK: - Properties

    /// The workout as last saved. The page reads this, so Add to Today takes the current one.
    @Published private(set) var template: WorkoutTemplateModel
    @Published var isPublic: Bool
    @Published private(set) var tags: [String]
    @Published private(set) var saveError: String?

    var hasChanges: Bool {
        isPublic != template.isPublic || tags != (template.tags ?? [])
    }

    // MARK: - Init

    init(
        template: WorkoutTemplateModel,
        saver: WorkoutTemplateUploading,
        libraryManager: WorkoutLibraryManager,
        now: @escaping () -> Date = Date.init
    ) {
        self.template = template
        self.saver = saver
        self.libraryManager = libraryManager
        self.now = now
        self.isPublic = template.isPublic
        self.tags = template.tags ?? []
    }

    // MARK: - Editing

    func addTag(_ raw: String) {
        tags = WorkoutTag.appending(raw, to: tags)
    }

    func removeTag(_ tag: String) {
        tags.removeAll { $0 == tag }
    }

    // MARK: - Saving

    func save() async {
        guard hasChanges else { return }
        // Whole seconds: the device's JSON stores dates to the second, so a finer stamp would read
        // back older than the copy in memory and could lose the merge to itself.
        let stamp = Date(timeIntervalSince1970: now().timeIntervalSince1970.rounded(.down))
        let updated = template.withSettings(isPublic: isPublic, tags: tags, updatedAt: stamp)
        do {
            try await saver.upload(updated)
            template = updated
            saveError = nil
            libraryManager.addTemplate(updated)
        } catch {
            isPublic = template.isPublic
            tags = template.tags ?? []
            saveError = "Couldn't save your changes. Try again."
        }
    }
}
