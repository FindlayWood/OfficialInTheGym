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
    
    @Published var selectedWellness: WellnessEntry?
    @Published var loadedWellness: [WellnessEntry] = []
    
    let saver: MyDayAndStatSaver
    let clipSaver: MyDaySaver
    let deleteSaver: MyDaySaver
    let loader: MyDayLoader
    let deleter: MyDayDeleter
    
    // wellness
    let wellnessSaver: MyDaySaver
    
    // rpe
    let rpeSaver: MyDaySaver

    // workouts
    let workoutSaver: MyDaySaver

    /// Raw stats logs for sets performed in a workout session. Exercises logged
    /// on their own get theirs from `saver`, which writes the day and the log
    /// together; a session already saves the day through `workoutSaver` after
    /// every set, so it needs the log on its own.
    let workoutStatsSaver: ExerciseStatsSaver

    public init(
        saver: MyDayAndStatSaver,
        clipSaver: MyDaySaver,
        deleteSaver: MyDaySaver,
        loader: MyDayLoader,
        deleter: MyDayDeleter,
        wellnessSaver: MyDaySaver,
        rpeSaver: MyDaySaver,
        workoutSaver: MyDaySaver,
        workoutStatsSaver: ExerciseStatsSaver
    ) {
        self.saver = saver
        self.clipSaver = clipSaver
        self.deleteSaver = deleteSaver
        self.loader = loader
        self.deleter = deleter
        self.wellnessSaver = wellnessSaver
        self.rpeSaver = rpeSaver
        self.workoutSaver = workoutSaver
        self.workoutStatsSaver = workoutStatsSaver
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
    
    func addNewCompletion(_ completion: ExerciseCompletions) {
        guard var selectedDay else { return }

        // 1. Try to find the exercise
        if let exerciseIndex = selectedDay.exercises.firstIndex(where: { $0.exercise.id == completion.exercise.id }) {
            
            // 2. If the exercise exists, look for this specific completion
            if let completionIndex = selectedDay.exercises[exerciseIndex]
                .completions
                .firstIndex(where: { $0.id == completion.id }) {

                // --- UPDATE ---
                selectedDay.exercises[exerciseIndex].completions[completionIndex] = completion

            } else {
                // --- APPEND NEW COMPLETION ---
                selectedDay.exercises[exerciseIndex].completions.append(completion)
            }

        } else {
            // 3. No exercise exists yet → create a new one
            let newExercise = MyDayExerciseModel(
                id: UUID().uuidString,
                date: .now,
                exercise: completion.exercise,
                completions: [completion],
                clips: []
            )

            selectedDay.exercises.append(newExercise)
        }

        // 4. Save updated state
        self.selectedDay = selectedDay

        let stats = completion.getStats()
        Task {
            try await saver.save(data: selectedDay, stats: stats)
        }
    }
    
    func addClipData(_ result: ClipUploadResult) {
        guard let selectedDay else { return }
        
        let clipData = MyDayClipModel(id: UUID().uuidString, clipID: result.clipID, exerciseID: result.exerciseID, dateUploaded: .now, thumbnailURL: result.thumbnailURL)

        // 1. Try to find the exercise
        if let exerciseIndex = selectedDay.exercises.firstIndex(where: { $0.exercise.id == result.exerciseID }) {
            
            // 2. If the exercise exists, add clip data
            selectedDay.exercises[exerciseIndex].clips.append(clipData)
            
        }

        // 3. Save updated state
        self.selectedDay = selectedDay

        Task {
            try await clipSaver.save(data: selectedDay)
        }
    }
    
    func deleteCompletion(_ completion: ExerciseCompletions) {
        guard var selectedDay else { return }

        // 1. Find the exercise that contains this completion
        guard let exerciseIndex = selectedDay.exercises.firstIndex(where: {
            $0.exercise.id == completion.exercise.id
        }) else {
            return
        }

        // 2. Find the specific completion inside that exercise
        guard let completionIndex = selectedDay.exercises[exerciseIndex]
            .completions
            .firstIndex(where: { $0.id == completion.id }) else {
            return
        }

        // 3. Remove the completion
        selectedDay.exercises[exerciseIndex].completions.remove(at: completionIndex)

        // 4. If the exercise is now empty, remove the entire exercise
        if selectedDay.exercises[exerciseIndex].completions.isEmpty {
            selectedDay.exercises.remove(at: exerciseIndex)
        }

        // 5. Save new state
        self.selectedDay = selectedDay

        Task {
            try await deleter.delete(at: "\(completion.exercise.id)/RawLogs/\(completion.id)")
            try await deleteSaver.save(data: selectedDay)
        }
    }
    
    
    func initialLoad() {
        Task {
            if let day: MyDayFullDayModel = try? await loader.load(for: .now) {
                self.loadedDays.append(day)
                self.selectedDay = day
            } else {
                self.selectedDay = MyDayFullDayModel(id: UUID().uuidString, date: .now, exercises: [], workouts: [])
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
                    self.selectedDay = MyDayFullDayModel(id: UUID().uuidString, date: date, exercises: [], workouts: [])
                }
            }
        }
    }
    
    // save wellness
    func saveWellnessEntry(_ entry: WellnessEntry) {
        guard var selectedDay else { return }
        
        selectedDay.wellnessEntry = entry
        
        self.selectedDay = selectedDay
        
        Task {
            try await wellnessSaver.save(data: selectedDay)
        }
    }
    
    // save rpe
    func saveRPEEntry(_ entry: RPEEntry) {
        guard var selectedDay else { return }
        
        selectedDay.rpeEntry = entry
        
        self.selectedDay = selectedDay
        
        Task {
            try await rpeSaver.save(data: selectedDay)
        }
    }
}
