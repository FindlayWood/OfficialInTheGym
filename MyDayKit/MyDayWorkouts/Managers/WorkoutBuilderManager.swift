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
                self.uploadState = .success
            }
        } catch {
            uploadState = .failure(error)
        }
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
            isPublic: false,
            tags: nil,
            estimatedDuration: nil,
            difficulty: nil,
            createdAt: now,
            updatedAt: now
        )
    }
}
