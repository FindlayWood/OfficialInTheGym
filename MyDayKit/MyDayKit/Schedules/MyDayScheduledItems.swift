//
//  MyDayScheduledItems.swift
//  MyDayKit
//
//  Created by Findlay Wood on 09/11/2026.
//

import Combine
import Foundation

/// What is due on MyDay: the user's schedules matched against the workout library, republished so the
/// home screen redraws when either changes.
///
/// **The library is read only when a workout is due.** It costs a Firestore read, and someone with
/// no schedules, or none today, should not pay it for opening MyDay.
final class MyDayScheduledItems: ObservableObject {

    /// Nothing scheduled, for previews and anything built without schedules.
    static var none: MyDayScheduledItems {
        MyDayScheduledItems(scheduleManager: nil, libraryManager: nil)
    }

    private let scheduleManager: ScheduleManager?
    private let libraryManager: WorkoutLibraryManager?
    private var subscriptions = Set<AnyCancellable>()

    init(scheduleManager: ScheduleManager?, libraryManager: WorkoutLibraryManager?) {
        self.scheduleManager = scheduleManager
        self.libraryManager = libraryManager

        scheduleManager?.objectWillChange
            .sink { [weak self] _ in self?.objectWillChange.send() }
            .store(in: &subscriptions)
        libraryManager?.objectWillChange
            .sink { [weak self] _ in self?.objectWillChange.send() }
            .store(in: &subscriptions)
    }

    func dueWorkouts(for day: MyDayFullDayModel) -> [DailyWorkoutEntry] {
        day.dueWorkouts(schedules: scheduleManager?.schedules ?? [], templates: templates)
    }

    func dueSports(for day: MyDayFullDayModel) -> [ScheduledSport] {
        day.dueSports(schedules: scheduleManager?.schedules ?? [])
    }

    /// Called each time the timeline appears. Only reaches for the library once the schedules are in
    /// and one of them is a workout due today.
    @MainActor
    func loadIfNeeded(today: Date = Date()) async {
        guard let scheduleManager else { return }
        await scheduleManager.loadIfNeeded()

        let isWorkoutDue = scheduleManager.due(on: ScheduleDay(today)).contains { schedule in
            if case .workout = schedule.item { return true }
            return false
        }
        if isWorkoutDue {
            libraryManager?.loadIfNeeded()
        }
    }

    private var templates: [WorkoutTemplateModel] {
        guard case .loaded(let templates) = libraryManager?.state else { return [] }
        return templates
    }
}
