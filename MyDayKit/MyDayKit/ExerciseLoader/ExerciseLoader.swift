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

/// What the picker lists: the catalogue and the user's custom exercises,
/// merged by `ExerciseLibrary`.
///
/// **The three reads are independent and each may fail alone.** The catalogue
/// failing still shows the user's own exercises, and the remote custom copy
/// failing is offline, not broken — the local files already hold everything
/// made on this device. Only all three coming back empty reads as no
/// exercises.
public class ExerciseManager: ObservableObject {

    @Published var isLoading: Bool = false
    @Published private(set) var library = ExerciseLibrary(catalogue: [], local: [], remote: [])

    var exercises: [Exercise] { library.exercises }
    
    let loader: ExerciseLoader
    let customLocal: CustomExerciseFetching
    let customRemote: CustomExerciseFetching
    
    public init(
        loader: ExerciseLoader,
        customLocal: CustomExerciseFetching = EmptyCustomExerciseFetching(),
        customRemote: CustomExerciseFetching = EmptyCustomExerciseFetching()
    ) {
        self.loader = loader
        self.customLocal = customLocal
        self.customRemote = customRemote
    }
    
    @MainActor
    func load() async {
        isLoading = true
        async let catalogue = read("exercises") { try await self.loader.loadAll() }
        async let local = read("local custom exercises") { try await self.customLocal.fetchAll() }
        async let remote = read("remote custom exercises") { try await self.customRemote.fetchAll() }
        library = ExerciseLibrary(catalogue: await catalogue, local: await local, remote: await remote)
        isLoading = false
    }

    private func read<T>(_ label: String, _ body: () async throws -> [T]) async -> [T] {
        do {
            return try await body()
        } catch {
            print("Error loading \(label): \(error)")
            return []
        }
    }
}

class PreviewExerciseLoader: ExerciseLoader {
    func loadAll() async throws -> [Exercise] {
        return []
    }
}
