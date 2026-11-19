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
    /// **Private by default** — a template reaches DISCOVER only when the
    /// author turns it public in the options sheet. It used to default to
    /// public, so every new user published their workouts without ever
    /// choosing to, and found out from a stranger's rating.
    @Published var isPublic: Bool = false
    @Published private(set) var tags: [String] = []
    @Published var uploadState: WorkoutUploadState = .idle
    /// The exercises joined to the one after them in a superset. Held as links rather than as
    /// `supersetId`s so the builder never has to invent or renumber ids while the user edits:
    /// the ids are minted once, in `buildTemplate()`.
    @Published private(set) var supersetLinks: Set<ObjectIdentifier> = []

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

    /// Removes exercises and drops any link left pointing past the end, so an exercise added
    /// later does not join a superset the user had already closed by deleting its last member.
    /// Removing one from the middle of a superset keeps the rest of it together.
    func removeExercises(atOffsets offsets: IndexSet) {
        exercises.remove(atOffsets: offsets)
        normaliseLinks()
    }

    // MARK: - Supersets

    /// Whether `exercise` is joined to the next one.
    func isLinkedToNext(_ exercise: WorkoutExerciseBuilderManager) -> Bool {
        supersetLinks.contains(ObjectIdentifier(exercise))
    }

    /// Joins `exercise` to the one after it, or splits them if they are joined. Joining onto an
    /// existing superset extends it (A–B linked, then B to C, is A–B–C); splitting in the middle
    /// leaves two supersets, or an exercise on its own. The last exercise has nothing to join.
    func toggleLink(after exercise: WorkoutExerciseBuilderManager) {
        guard let index = exercises.firstIndex(of: exercise), index < exercises.count - 1 else { return }
        let id = ObjectIdentifier(exercise)
        if supersetLinks.contains(id) {
            supersetLinks.remove(id)
        } else {
            supersetLinks.insert(id)
        }
    }

    /// The builder's exercises as `WorkoutSupersetLayout` reads them, for the labels it draws while
    /// building. The ids only need to compare equal within a group.
    var supersetLayout: WorkoutSupersetLayout {
        WorkoutSupersetLayout(supersetIds: Self.supersetIds(linkedToNext: linkedToNext, makeId: { "\($0)" }))
    }

    private var linkedToNext: [Bool] {
        exercises.map(isLinkedToNext)
    }

    private func normaliseLinks() {
        let present = Set(exercises.dropLast().map(ObjectIdentifier.init))
        supersetLinks.formIntersection(present)
    }

    /// One id per group of linked exercises, `nil` for an exercise on its own. `makeId` is given the
    /// group's first index, so tests and the builder's labels can use something stable while
    /// `buildTemplate()` mints UUIDs.
    static func supersetIds(linkedToNext: [Bool], makeId: (Int) -> String) -> [String?] {
        var ids: [String?] = []
        var current: String?
        for (index, linked) in linkedToNext.enumerated() {
            let joinedFromPrevious = index > 0 && linkedToNext[index - 1]
            if joinedFromPrevious {
                ids.append(current)
            } else if linked {
                current = makeId(index)
                ids.append(current)
            } else {
                current = nil
                ids.append(nil)
            }
        }
        return ids
    }

    // MARK: - Tags

    /// Normalises through `WorkoutTag`, and ignores a tag that normalises to
    /// nothing or is already added.
    func addTag(_ tag: String) {
        tags = WorkoutTag.appending(tag, to: tags)
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
    /// visibility and tags — a public workout must not leave the next one
    /// public, or carry its tags into it.
    private func reset() {
        title = ""
        exercises = []
        isPublic = false
        tags = []
        supersetLinks = []
    }

    // MARK: - Private

    private func buildTemplate() -> WorkoutTemplateModel {
        let now = Date()
        let supersetIds = Self.supersetIds(linkedToNext: linkedToNext, makeId: { _ in UUID().uuidString })
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
                        setManager.setModel(orderIndex: setIndex, id: UUID().uuidString)
                    },
                    muscleGroups: manager.exercise.muscleGroups,
                    movementPatterns: manager.exercise.movementPatterns,
                    supersetId: supersetIds[index]
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
