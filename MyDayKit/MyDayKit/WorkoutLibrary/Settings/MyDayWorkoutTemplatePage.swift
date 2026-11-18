//
//  MyDayWorkoutTemplatePage.swift
//  MyDayKit
//
//  Created by Findlay Wood on 13/11/2026.
//

import SwiftUI

/// The workout page, editable or not. **The one place that decides whether a workout gets its `⋯`**,
/// used by both ways the page opens: MyDay's library (`MyDayWorkoutCoordinator`) and another tab
/// (`MyDayWorkoutLibraryRouter`). Deciding it in each would let the two disagree about which
/// workouts a user may publish.
///
/// A workout is editable when settings were provided and the user built it themselves
/// (`WorkoutTemplateModel.isEditable(by:)`).
struct MyDayWorkoutTemplatePage: View {

    let template: WorkoutTemplateModel
    let editor: WorkoutTemplateSettingsEditor?
    var scheduleManager: ScheduleManager?
    var onAddToTodayTapped: ((WorkoutTemplateModel) -> Void)?
    var onReadyToDismiss: (() -> Void)?
    var onBack: (() -> Void)?

    @MainActor
    init(
        template: WorkoutTemplateModel,
        settings: WorkoutTemplateSettingsDependencies?,
        libraryManager: WorkoutLibraryManager,
        scheduleManager: ScheduleManager?,
        onAddToTodayTapped: ((WorkoutTemplateModel) -> Void)?,
        onReadyToDismiss: (() -> Void)?,
        onBack: (() -> Void)?
    ) {
        self.template = template
        if let settings, template.isEditable(by: settings.userId) {
            editor = WorkoutTemplateSettingsEditor(
                template: template,
                saver: settings.saver,
                libraryManager: libraryManager
            )
        } else {
            editor = nil
        }
        self.scheduleManager = scheduleManager
        self.onAddToTodayTapped = onAddToTodayTapped
        self.onReadyToDismiss = onReadyToDismiss
        self.onBack = onBack
    }

    var body: some View {
        if let editor {
            MyDayEditableWorkoutTemplateScreen(
                editor: editor,
                scheduleManager: scheduleManager,
                onAddToTodayTapped: onAddToTodayTapped,
                onReadyToDismiss: onReadyToDismiss,
                onBack: onBack
            )
        } else {
            MyDayWorkoutTemplateDetailScreen(
                template: template,
                scheduleManager: scheduleManager,
                onAddToTodayTapped: onAddToTodayTapped,
                onReadyToDismiss: onReadyToDismiss,
                onBack: onBack
            )
        }
    }
}
