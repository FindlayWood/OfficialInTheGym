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
    
    let saver: MyDaySaver
    let loader: MyDayLoader
    
//    let storage = MyDayStorage()
    
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

//final class CurrentDayLoader {
//    private let loader: MyDayLoader
//    init(loader: MyDayLoader) {
//        self.loader = loader
//    }
//    
//    func load<T: Codable>(for date: Date) async throws -> T? {
//        try await loader.load(for: date)
//    }
//}
//
//final class PreviousDayLoader {
//    private let loader: MyDayLoader
//    init(loader: MyDayLoader) {
//        self.loader = loader
//    }
//    
//    func load<T: Codable>(for date: Date) async throws -> T? {
//        try await loader.load(for: date)
//    }
//}

//struct MyDayStorage {
//    
//    private static var baseURL: URL {
//        let docs = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask).first!
//        let dir = docs.appendingPathComponent("MyDays", isDirectory: true)
//        
//        if !FileManager.default.fileExists(atPath: dir.path) {
//            try? FileManager.default.createDirectory(at: dir, withIntermediateDirectories: true)
//        }
//        return dir
//    }
//    
//    private static func fileURL(for date: Date) -> URL {
//        let formatter = DateFormatter()
//        formatter.dateFormat = "yyyy-MM-dd"
//        let filename = formatter.string(from: date) + ".json"
//        return baseURL.appendingPathComponent(filename)
//    }
//    
//    // Save or update today's file
//    static func save(day: MyDayFullDayModel, completion: ((Error?) -> Void)? = nil) {
//        DispatchQueue.global(qos: .background).async {
//            do {
//                let data = try JSONEncoder().encode(day)
//                try data.write(to: fileURL(for: day.date), options: [.atomic])
//                DispatchQueue.main.async { completion?(nil) }
//            } catch {
//                DispatchQueue.main.async { completion?(error) }
//            }
//        }
//    }
//    
//    // Load a specific day's model
//    static func load(for date: Date, completion: @escaping (MyDayFullDayModel?) -> Void) {
//        DispatchQueue.global(qos: .background).async {
//            do {
//                let url = fileURL(for: date)
//                guard FileManager.default.fileExists(atPath: url.path) else {
//                    DispatchQueue.main.async { completion(nil) }
//                    return
//                }
//                let data = try Data(contentsOf: url)
//                let day = try JSONDecoder().decode(MyDayFullDayModel.self, from: data)
//                DispatchQueue.main.async { completion(day) }
//            } catch {
//                print("❌ Error loading day: \(error)")
//                DispatchQueue.main.async { completion(nil) }
//            }
//        }
//    }
//    
//    // Load a specific day's model (async/await)
//    static func load(for date: Date) async throws -> MyDayFullDayModel? {
//        let url = fileURL(for: date)
//        guard FileManager.default.fileExists(atPath: url.path) else {
//            return nil
//        }
//        
//        let data = try Data(contentsOf: url)
//        let day = try JSONDecoder().decode(MyDayFullDayModel.self, from: data)
//        return day
//    }
//    
//    // Update a day with a new completion
//    static func addCompletion(_ newCompletion: ExerciseCompletions, for date: Date, completion: ((Error?) -> Void)? = nil) {
//        load(for: date) { existingDay in
//            var day = existingDay ?? MyDayFullDayModel(
//                id: UUID().uuidString,
//                date: date,
//                exercises: []
//            )
//            
//            if let index = day.exercises.firstIndex(where: { $0.exercise.id == newCompletion.exercise.id }) {
//                day.exercises[index].completions.append(newCompletion)
//            } else {
//                let newExercise = MyDayExerciseModel(
//                    id: UUID().uuidString,
//                    date: date,
//                    exercise: newCompletion.exercise,
//                    completions: [newCompletion]
//                )
//                day.exercises.append(newExercise)
//            }
//            
//            save(day: day, completion: completion)
//        }
//    }
//}

//import Foundation
//
//final class MyDayFileManagerSaver: MyDaySaver {
//    private let baseURL: URL
//
//    init() {
//        let docs = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask).first!
//        let dir = docs.appendingPathComponent("MyDays", isDirectory: true)
//
//        if !FileManager.default.fileExists(atPath: dir.path) {
//            try? FileManager.default.createDirectory(at: dir, withIntermediateDirectories: true)
//        }
//
//        self.baseURL = dir
//    }
//
//    private func fileURL(for path: String) -> URL {
//        return baseURL.appendingPathComponent(path)
//    }
//
//    func save<T: Codable>(data: T) async throws {
//        let url = fileURL(for: path)
//        let encoded = try JSONEncoder().encode(data)
//        try encoded.write(to: url, options: [.atomic])
//    }
//}
