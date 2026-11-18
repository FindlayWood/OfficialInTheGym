//
//  MyDayEditableWorkoutTemplateScreen.swift
//  MyDayKit
//
//  Created by Findlay Wood on 13/11/2026.
//

import SwiftUI

/// The workout page for a workout the user may change: `MyDayWorkoutTemplateDetailScreen` drawn from
/// the editor's current template, with the `⋯` opening `WorkoutTemplateSettingsSheet`.
///
/// A wrapper rather than an optional editor on the page itself, because SwiftUI cannot observe an
/// optional object, and the page has to redraw when a save lands (the chip, and the template Add to
/// Today takes). **Closing the sheet saves**, however it is closed: Done or a swipe down.
struct MyDayEditableWorkoutTemplateScreen: View {

    @ObservedObject var editor: WorkoutTemplateSettingsEditor
    var scheduleManager: ScheduleManager?
    var onAddToTodayTapped: ((WorkoutTemplateModel) -> Void)?
    var onReadyToDismiss: (() -> Void)?
    var onBack: (() -> Void)?

    @State private var showsSettings = false

    var body: some View {
        MyDayWorkoutTemplateDetailScreen(
            template: editor.template,
            scheduleManager: scheduleManager,
            onAddToTodayTapped: onAddToTodayTapped,
            onReadyToDismiss: onReadyToDismiss,
            onBack: onBack,
            onSettingsTapped: { showsSettings = true },
            settingsNotice: editor.saveError
        )
        .sheet(isPresented: $showsSettings, onDismiss: {
            Task { await editor.save() }
        }) {
            WorkoutTemplateSettingsSheet(editor: editor)
        }
    }
}
