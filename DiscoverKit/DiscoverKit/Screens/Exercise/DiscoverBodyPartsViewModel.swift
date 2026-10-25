//
//  DiscoverBodyPartsViewModel.swift
//  DiscoverKit
//
//  Created by Findlay Wood on 25/10/2026.
//

import Combine
import Foundation

/// The exercise page's "Works" section: what the exercise works, by name, and
/// the user's suggestion of a change.
///
/// **The section shows what the catalogue says, never the votes.** Votes are
/// suggestions a curator reviews; showing the tally here would present a
/// crowd's guess as fact, beside the numbers training balance actually uses.
/// The user's own suggestion is acknowledged, not displayed as the answer.
@MainActor
final class DiscoverBodyPartsViewModel: ObservableObject {

    let exerciseId: String
    let currentMuscleGroups: [String]
    let currentMovementPatterns: [String]

    @Published private(set) var parts: DiscoverBodyParts?
    @Published private(set) var myVote: DiscoverBodyVote?
    @Published private(set) var didFailToLoad = false
    @Published var isSheetPresented = false
    @Published var draftMuscleGroups: Set<String> = []
    @Published var draftMovementPatterns: Set<String> = []
    @Published private(set) var isSaving = false
    @Published private(set) var saveError: String?

    private let partsLoader: BodyPartsLoader
    private let myVoteLoader: MyBodyVoteLoader
    private let writer: BodyVoteWriter

    init(
        exerciseId: String,
        muscleGroups: [String]?,
        movementPatterns: [String]?,
        partsLoader: BodyPartsLoader,
        myVoteLoader: MyBodyVoteLoader,
        writer: BodyVoteWriter
    ) {
        self.exerciseId = exerciseId
        self.currentMuscleGroups = muscleGroups ?? []
        self.currentMovementPatterns = movementPatterns ?? []
        self.partsLoader = partsLoader
        self.myVoteLoader = myVoteLoader
        self.writer = writer
    }

    /// "Chest", "Triceps", "Push Horizontal" — muscle groups first.
    var worksNames: [String] {
        parts?.names(muscleGroups: currentMuscleGroups, movementPatterns: currentMovementPatterns) ?? []
    }

    /// A suggestion is a whole set: at least one of each.
    var isDraftComplete: Bool {
        !draftMuscleGroups.isEmpty && !draftMovementPatterns.isEmpty
    }

    func load() async {
        do {
            async let parts = partsLoader.loadBodyParts()
            async let vote = try? myVoteLoader.myBodyVote(onExercise: exerciseId)
            self.parts = try await parts
            self.myVote = await vote ?? nil
        } catch {
            didFailToLoad = true
        }
    }

    /// Opens on the user's last suggestion, or else on what the exercise says.
    func openSheet() {
        draftMuscleGroups = Set(myVote?.muscleGroups ?? currentMuscleGroups)
        draftMovementPatterns = Set(myVote?.movementPatterns ?? currentMovementPatterns)
        saveError = nil
        isSheetPresented = true
    }

    /// **Each tap saves**, as the tag sheet does, so Done only dismisses. A
    /// set emptied of muscle groups or patterns is not sent — the last
    /// complete one stands until it is complete again.
    func toggleMuscleGroup(_ id: String) async {
        if draftMuscleGroups.contains(id) { draftMuscleGroups.remove(id) } else { draftMuscleGroups.insert(id) }
        await save()
    }

    func toggleMovementPattern(_ id: String) async {
        if draftMovementPatterns.contains(id) { draftMovementPatterns.remove(id) } else { draftMovementPatterns.insert(id) }
        await save()
    }

    private func save() async {
        guard isDraftComplete, let parts else { return }
        // In the lists' order, so the stored vote does not depend on tap order.
        let vote = DiscoverBodyVote(
            muscleGroups: parts.muscleGroups.map(\.id).filter(draftMuscleGroups.contains),
            movementPatterns: parts.movementPatterns.map(\.id).filter(draftMovementPatterns.contains)
        )
        isSaving = true
        defer { isSaving = false }
        do {
            try await writer.setMyBodyVote(vote, onExercise: exerciseId)
            myVote = vote
            saveError = nil
        } catch {
            saveError = "Couldn't send your suggestion. Try again."
        }
    }
}
