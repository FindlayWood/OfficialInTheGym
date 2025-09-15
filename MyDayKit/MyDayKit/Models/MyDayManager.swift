//
//  MyDayManager.swift
//  MyDayKit
//
//  Created by Findlay Wood on 13/08/2025.
//

import Combine
import Foundation

public class MyDayManager: ObservableObject {
    
//    @Published var completedExercises: [MyDayExerciseModel] = []
    
    @Published var loadedDays: [MyDayFullDayModel] = []
    
    @Published var selectedDay: MyDayFullDayModel?
    
    let storage = MyDayStorage()
    
    public init() {
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
            MyDayStorage.save(day: selectedDay)
        } else {
            let newExercise = MyDayExerciseModel(
                id: UUID().uuidString,
                date: .now,
                exercise: newCompletion.exercise,
                completions: [newCompletion]
            )
            selectedDay.exercises.append(newExercise)
            self.selectedDay = selectedDay
            MyDayStorage.save(day: selectedDay)
        }
    }
    
    func initialLoad() {
        MyDayStorage.load(for: .now) { [weak self] model in
            if let model {
                self?.loadedDays.append(model)
                self?.selectedDay = model
            } else {
                self?.selectedDay = MyDayFullDayModel(id: UUID().uuidString, date: .now, exercises: [])
            }
        }
    }
    
    func loadDay(_ date: Date) {
        MyDayStorage.load(for: date) { [weak self] model in
            if let model {
                self?.loadedDays.append(model)
                self?.selectedDay = model
            } else {
                self?.selectedDay = MyDayFullDayModel(id: UUID().uuidString, date: date, exercises: [])
            }
        }
    }
}


struct MyDayStorage {
    
    private static var baseURL: URL {
        let docs = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask).first!
        let dir = docs.appendingPathComponent("MyDays", isDirectory: true)
        
        if !FileManager.default.fileExists(atPath: dir.path) {
            try? FileManager.default.createDirectory(at: dir, withIntermediateDirectories: true)
        }
        return dir
    }
    
    private static func fileURL(for date: Date) -> URL {
        let formatter = DateFormatter()
        formatter.dateFormat = "yyyy-MM-dd"
        let filename = formatter.string(from: date) + ".json"
        return baseURL.appendingPathComponent(filename)
    }
    
    // Save or update today's file
    static func save(day: MyDayFullDayModel, completion: ((Error?) -> Void)? = nil) {
        DispatchQueue.global(qos: .background).async {
            do {
                let data = try JSONEncoder().encode(day)
                try data.write(to: fileURL(for: day.date), options: [.atomic])
                DispatchQueue.main.async { completion?(nil) }
            } catch {
                DispatchQueue.main.async { completion?(error) }
            }
        }
    }
    
    // Load a specific day's model
    static func load(for date: Date, completion: @escaping (MyDayFullDayModel?) -> Void) {
        DispatchQueue.global(qos: .background).async {
            do {
                let url = fileURL(for: date)
                guard FileManager.default.fileExists(atPath: url.path) else {
                    DispatchQueue.main.async { completion(nil) }
                    return
                }
                let data = try Data(contentsOf: url)
                let day = try JSONDecoder().decode(MyDayFullDayModel.self, from: data)
                DispatchQueue.main.async { completion(day) }
            } catch {
                print("❌ Error loading day: \(error)")
                DispatchQueue.main.async { completion(nil) }
            }
        }
    }
    
    // Load a specific day's model (async/await)
    static func load(for date: Date) async throws -> MyDayFullDayModel? {
        let url = fileURL(for: date)
        guard FileManager.default.fileExists(atPath: url.path) else {
            return nil
        }
        
        let data = try Data(contentsOf: url)
        let day = try JSONDecoder().decode(MyDayFullDayModel.self, from: data)
        return day
    }
    
    // Update a day with a new completion
    static func addCompletion(_ newCompletion: ExerciseCompletions, for date: Date, completion: ((Error?) -> Void)? = nil) {
        load(for: date) { existingDay in
            var day = existingDay ?? MyDayFullDayModel(
                id: UUID().uuidString,
                date: date,
                exercises: []
            )
            
            if let index = day.exercises.firstIndex(where: { $0.exercise.id == newCompletion.exercise.id }) {
                day.exercises[index].completions.append(newCompletion)
            } else {
                let newExercise = MyDayExerciseModel(
                    id: UUID().uuidString,
                    date: date,
                    exercise: newCompletion.exercise,
                    completions: [newCompletion]
                )
                day.exercises.append(newExercise)
            }
            
            save(day: day, completion: completion)
        }
    }
}
