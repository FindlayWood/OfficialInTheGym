//
//  ExerciseLoader.swift
//  MyDayKit
//
//  Created by Findlay Wood on 05/08/2025.
//

import Combine
import Foundation

public protocol ExerciseLoader {
    func loadAll() async throws -> [Exercise]
}

public class ExerciseManager: ObservableObject {

    @Published var isLoading: Bool = false
    @Published var exercises: [Exercise] = []
    
    let loader: ExerciseLoader
    
    public init(loader: ExerciseLoader) {
        self.loader = loader
    }
    
    @MainActor
    func load() async {
        isLoading = true
        do {
            exercises = try await loader.loadAll()
            isLoading = false
        } catch {
            print("Error loading exercises: \(error)")
            isLoading = false
        }
    }
}

class PreviewExerciseLoader: ExerciseLoader {
    func loadAll() async throws -> [Exercise] {
        return []
    }
}
