//
//  WorkoutBuilderManager.swift
//  MyDayKit
//
//  Created by Findlay Wood on 03/06/2026.
//

import Combine
import Foundation

// MARK: - Upload State

public enum WorkoutUploadState {
    case idle
    case uploading
    case success
    case failure(Error)
}
 
extension WorkoutUploadState: Equatable {
    public static func == (lhs: WorkoutUploadState, rhs: WorkoutUploadState) -> Bool {
        switch (lhs, rhs) {
        case (.idle, .idle): return true
        case (.uploading, .uploading): return true
        case (.success, .success): return true
        case (.failure, .failure): return true
        default: return false
        }
    }
}

// MARK: - Manager

public final class WorkoutBuilderManager: ObservableObject {

    // MARK: - Published state

    @Published var title: String = ""
    @Published var exercises: [WorkoutExerciseBuilderManager] = []
    /// Public by default — templates are shared unless the author opts out in
    /// the options sheet.
    @Published var isPublic: Bool = true
    @Published private(set) var tags: [String] = []
    @Published var uploadState: WorkoutUploadState = .idle

    public var onUploadSuccess: ((WorkoutTemplateModel) -> Void)?

    // MARK: - Dependencies

    private let uploader: WorkoutTemplateUploading
    private let userId: String

    // MARK: - Init

    public init(uploader: WorkoutTemplateUploading, userId: String = "") {
        self.uploader = uploader
        self.userId = userId
    }
    
    // MARK: - Add Exercise
    func addExercise(_ exercise: WorkoutExerciseBuilderManager) {
        exercises.append(exercise)
    }

    // MARK: - Tags

    /// Normalises through `WorkoutTag`, and ignores a tag that normalises to
    /// nothing or is already added.
    func addTag(_ tag: String) {
        let normalized = WorkoutTag.normalized(tag)
        guard !normalized.isEmpty, !tags.contains(normalized) else { return }
        tags.append(normalized)
    }

    func removeTag(_ tag: String) {
        tags.removeAll { $0 == tag }
    }

    // MARK: - Upload

    public func uploadWorkout() async {
        guard !title.isEmpty, !exercises.isEmpty else { return }

        await MainActor.run {
            self.uploadState = .uploading
        }

        let template = buildTemplate()

        do {
            try await uploader.upload(template)
            await MainActor.run {
                self.onUploadSuccess?(template)
                // Reset before publishing `.success`: that is what pops the
                // screen, and this manager is built once in the composition
                // root and outlives it — so anything left here is what the
                // next visit to the builder opens with.
                self.reset()
                self.uploadState = .success
            }
        } catch {
            // Nothing is reset on failure — the user's input is what they
            // need to try again.
            await MainActor.run {
                self.uploadState = .failure(error)
            }
        }
    }

    // MARK: - Reset

    /// Clears everything the builder collects, including the options sheet's
    /// visibility and tags — a private workout must not leave the next one
    /// private, or carry its tags into it.
    private func reset() {
        title = ""
        exercises = []
        isPublic = true
        tags = []
    }

    // MARK: - Private

    private func buildTemplate() -> WorkoutTemplateModel {
        let now = Date()
        return WorkoutTemplateModel(
            id: UUID().uuidString,
            title: title,
            description: nil,
            exercises: exercises.enumerated().map { index, manager in
                WorkoutExerciseModel(
                    id: UUID().uuidString,
                    exerciseId: manager.exercise.id,
                    exerciseName: manager.exercise.name,
                    exerciseCategory: manager.exercise.category,
                    orderIndex: index,
                    sets: manager.sets.enumerated().map { setIndex, setManager in
                        WorkoutSetModel(
                            id: UUID().uuidString,
                            orderIndex: setIndex,
                            reps: setManager.reps,
                            weight: setManager.weight,
                            weightUnit: setManager.weightUnits,
                            time: setManager.time,
                            distance: setManager.distance,
                            distanceUnit: setManager.distanceUnits,
                            tempo: setManager.tempo,
                            note: setManager.note,
                            eachSide: setManager.eachSide
                        )
                    }
                )
            },
            createdBy: userId,
            isPublic: isPublic,
            tags: tags,
            estimatedDuration: nil,
            difficulty: nil,
            createdAt: now,
            updatedAt: now
        )
    }
}
