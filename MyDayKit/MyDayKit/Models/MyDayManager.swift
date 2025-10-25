//
//  MyDayManager.swift
//  MyDayKit
//
//  Created by Findlay Wood on 13/08/2025.
//

import Combine
import Foundation

public class MyDayManager: ObservableObject {
    
    @Published var loadedDays: [MyDayFullDayModel] = []
    
    @Published var selectedDay: MyDayFullDayModel?
    
    let saver: MyDaySaver
    let loader: MyDayLoader
    
    public init(saver: MyDaySaver, loader: MyDayLoader) {
        self.saver = saver
        self.loader = loader
        initialLoad()
    }
    
    func isDaySelected(_ day: Date) -> Bool {
        guard let selectedDay else { return false }
        return Calendar.current.isDate(day, inSameDayAs: selectedDay.date)
    }
    
    func isTodaySelected() -> Bool {
        guard let selectedDay else { return false }
        return Calendar.current.isDate(.now, inSameDayAs: selectedDay.date)
    }
    
    func changeSelectedDay(to newDate: Date) {
        loadDay(newDate)
    }
    
    func addNewCompletion(_ newCompletion: ExerciseCompletions) {
        guard var selectedDay else { return }
        if let existingCompletion = selectedDay.exercises.first(where: { $0.exercise.id == newCompletion.exercise.id }) {
            existingCompletion.completions.append(newCompletion)
            self.selectedDay = selectedDay
            Task {
                try await saver.save(data: selectedDay)
            }
        } else {
            let newExercise = MyDayExerciseModel(
                id: UUID().uuidString,
                date: .now,
                exercise: newCompletion.exercise,
                completions: [newCompletion]
            )
            selectedDay.exercises.append(newExercise)
            self.selectedDay = selectedDay
            Task {
                try await saver.save(data: selectedDay)
            }
        }
    }
    
    func initialLoad() {
        Task {
            if let day: MyDayFullDayModel = try? await loader.load(for: .now) {
                self.loadedDays.append(day)
                self.selectedDay = day
            } else {
                self.selectedDay = MyDayFullDayModel(id: UUID().uuidString, date: .now, exercises: [])
            }
        }
    }
    
    func loadDay(_ date: Date) {
        Task {
            if let day: MyDayFullDayModel = try? await loader.load(for: date) {
                await MainActor.run {
                    self.loadedDays.append(day)
                    self.selectedDay = day
                }
            } else {
                await MainActor.run {
                    self.selectedDay = MyDayFullDayModel(id: UUID().uuidString, date: date, exercises: [])
                }
            }
        }
    }
}
