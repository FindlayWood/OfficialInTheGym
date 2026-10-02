//
//  DiscoverWorkoutDetailViewModel.swift
//  DiscoverKit
//
//  Created by Findlay Wood on 02/10/2026.
//

import Combine
import Foundation

/// A workout's page beyond its rating, tags and comments: what is in it, who
/// made it, and saving a copy to the user's own library.
///
/// The contents are read when the page opens — a list card carries none — and
/// a failure there is its own state with a retry, never an empty workout.
/// Whether a copy is already saved is checked first, so a workout saved last
/// week reads "Saved" rather than inviting a second copy.
@MainActor
final class DiscoverWorkoutDetailViewModel: ObservableObject {

    @Published private(set) var detail: DiscoverSectionState<DiscoverWorkoutDetail> = .loading
    @Published private(set) var authorName: String?
    @Published private(set) var saveState: DiscoverWorkoutSaveState

    let templateId: String
    private let createdBy: String?
    private let detailLoader: DiscoverWorkoutDetailLoader
    private let profileLoader: UserProfileLoader
    private let copySaver: WorkoutCopySaver?
    private let copyChecker: SavedWorkoutCopyChecker?

    /// `copySaver` and `copyChecker` are nil where there is no library — the
    /// coach tab bar — and the router passes nil on the user's own workout.
    init(
        templateId: String,
        createdBy: String?,
        detailLoader: DiscoverWorkoutDetailLoader,
        profileLoader: UserProfileLoader,
        copySaver: WorkoutCopySaver?,
        copyChecker: SavedWorkoutCopyChecker?
    ) {
        self.templateId = templateId
        self.createdBy = createdBy
        self.detailLoader = detailLoader
        self.profileLoader = profileLoader
        self.copySaver = copySaver
        self.copyChecker = copyChecker
        self.saveState = copySaver == nil ? .unavailable : .checking
    }

    func load() async {
        async let contents: Void = loadDetail()
        async let author: Void = loadAuthor()
        async let saved: Void = checkSaved()
        _ = await (contents, author, saved)
    }

    func loadDetail() async {
        detail = .loading
        do {
            detail = .loaded(try await detailLoader.detail(ofWorkout: templateId))
        } catch {
            print("❌ Workout detail failed: \(error)")
            detail = .failed
        }
    }

    private func loadAuthor() async {
        guard let createdBy, let profiles = try? await profileLoader.profiles(for: [createdBy]) else { return }
        authorName = profiles[createdBy]?.name
    }

    private func checkSaved() async {
        guard saveState == .checking else { return }
        let saved = await copyChecker?.hasSavedCopy(ofWorkout: templateId) ?? false
        saveState = saved ? .saved : .idle
    }

    func save() async {
        guard let copySaver, saveState == .idle || saveState == .failed else { return }
        saveState = .saving
        do {
            try await copySaver.saveCopy(ofWorkout: templateId)
            saveState = .saved
        } catch {
            print("❌ Save to library failed: \(error)")
            saveState = .failed
        }
    }
}
