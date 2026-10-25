//
//  CustomExerciseFormModel.swift
//  MyDayKit
//
//  Created by Findlay Wood on 25/10/2026.
//

import Combine
import Foundation

/// The state behind `CustomExerciseFormScreen`: the six answers, the lists to
/// choose from, and the save.
///
/// **Complete or not saved.** Every field a catalogue exercise has is required
/// — name, category, at least one muscle group, at least one movement pattern,
/// compound and unilateral — so an approved exercise needs nothing filled in
/// afterwards. `canSave` is the one gate, and the screen draws the button from
/// it rather than checking anything itself.
///
/// **Compound and unilateral start unanswered** (`Bool?`), not `false`. A
/// preselected answer would count as given when the user never chose it, and
/// it would land in training balance as fact.
///
/// Built by the coordinators, which are not main-actor isolated, so the
/// methods that publish are marked rather than the whole class.
final class CustomExerciseFormModel: ObservableObject {

    enum Options {
        case loading
        case loaded(muscleGroups: [ExerciseMuscleGroup], movementPatterns: [ExerciseMovementPattern])
        case failed
    }

    /// Long enough for "Single-Arm Landmine Rotational Press", short enough for
    /// a picker row.
    static let maxNameLength = 60

    @Published var name: String {
        didSet {
            if name.count > Self.maxNameLength {
                name = String(name.prefix(Self.maxNameLength))
            }
        }
    }
    @Published var category: ExerciseCategory?
    @Published var muscleGroups: Set<String> = []
    @Published var movementPatterns: Set<String> = []
    @Published var isCompound: Bool?
    @Published var isUnilateral: Bool?

    @Published private(set) var options: Options = .loading
    @Published private(set) var isSaving = false
    @Published private(set) var saveError: String?
    /// Exercises that work the same way, found on the first Save; non-nil
    /// shows the "save anyway?" card.
    @Published var similarOnSave: [Exercise]?

    private let dependencies: CustomExerciseDependencies
    /// What the picker lists — the catalogue and the user's own — which both
    /// similar-exercise checks look through.
    private let existingExercises: [Exercise]
    /// The body check asks once per form. Asking again on every Save would
    /// turn a nudge into a gate.
    private var hasAskedAboutSimilar = false

    init(name: String = "", existingExercises: [Exercise] = [], dependencies: CustomExerciseDependencies) {
        self.name = String(name.prefix(Self.maxNameLength))
        self.existingExercises = existingExercises
        self.dependencies = dependencies
    }

    // MARK: - Similar exercises

    /// A shorter name matches almost anything and says nothing yet.
    static let nameMatchMinimumLength = 3

    /// "Did you mean…?" — exercises already in the list whose name is close to
    /// the one typed, best first. Each is offered in place of creating a copy.
    var nameMatches: [Exercise] {
        guard cleanedName.count >= Self.nameMatchMinimumLength else { return [] }
        return dependencies.similarExercises.exercises(named: cleanedName, in: existingExercises, limit: 3)
    }

    /// Exercises that work the same way under another name — see
    /// `ExerciseBodySimilarity`.
    var bodyMatches: [Exercise] {
        ExerciseBodySimilarity.matches(
            muscleGroups: muscleGroups,
            movementPatterns: movementPatterns,
            excludingName: cleanedName,
            in: existingExercises,
            limit: 3
        )
    }

    // MARK: - Validation

    /// Trimmed, with runs of spaces collapsed — what is stored, and what the
    /// name can never be changed from.
    var cleanedName: String {
        name.split(whereSeparator: \.isWhitespace).joined(separator: " ")
    }

    var canSave: Bool {
        !cleanedName.isEmpty
            && category != nil
            && !muscleGroups.isEmpty
            && !movementPatterns.isEmpty
            && isCompound != nil
            && isUnilateral != nil
            && !isSaving
    }

    // MARK: - Options

    @MainActor
    func loadOptions() async {
        options = .loading
        do {
            async let groups = dependencies.muscleGroups.loadMuscleGroups()
            async let patterns = dependencies.movementPatterns.loadMovementPatterns()
            let loaded = (try await groups, try await patterns)
            // Both lists empty is as unusable as a failure: nothing can be picked,
            // so nothing can be saved.
            options = loaded.0.isEmpty || loaded.1.isEmpty
                ? .failed
                : .loaded(muscleGroups: loaded.0, movementPatterns: loaded.1)
        } catch {
            print("❌ Couldn't load exercise options: \(error)")
            options = .failed
        }
    }

    @MainActor
    func toggleMuscleGroup(_ id: String) {
        if muscleGroups.contains(id) { muscleGroups.remove(id) } else { muscleGroups.insert(id) }
    }

    @MainActor
    func toggleMovementPattern(_ id: String) {
        if movementPatterns.contains(id) { movementPatterns.remove(id) } else { movementPatterns.insert(id) }
    }

    // MARK: - Save

    /// Save, unless this is the first attempt and something already works
    /// the same way — then `similarOnSave` is set and nothing is saved. It
    /// asks once, never blocks: the next Save goes through.
    @MainActor
    func saveOrAskFirst() async -> CustomExercise? {
        guard canSave else { return nil }
        if !hasAskedAboutSimilar {
            hasAskedAboutSimilar = true
            let matches = bodyMatches
            if !matches.isEmpty {
                similarOnSave = matches
                return nil
            }
        }
        return await save()
    }

    /// Saves and returns the exercise, or `nil` with `saveError` set. Only the
    /// local write can fail it; the remote copies are queued if they fail.
    @MainActor
    func save() async -> CustomExercise? {
        guard canSave,
              let category, let isCompound, let isUnilateral,
              case let .loaded(groupOptions, patternOptions) = options
        else { return nil }

        // In the lists' own order, so the stored arrays do not depend on the
        // order the chips were tapped in.
        let exercise = CustomExercise(
            name: cleanedName,
            category: category,
            muscleGroups: groupOptions.map(\.id).filter(muscleGroups.contains),
            movementPatterns: patternOptions.map(\.id).filter(movementPatterns.contains),
            isCompound: isCompound,
            isUnilateral: isUnilateral,
            createdBy: dependencies.userId
        )

        isSaving = true
        saveError = nil
        defer { isSaving = false }
        do {
            try await dependencies.saver.upload(exercise)
            return exercise
        } catch {
            print("❌ Couldn't save custom exercise: \(error)")
            saveError = "Couldn't save the exercise. Try again."
            return nil
        }
    }
}
