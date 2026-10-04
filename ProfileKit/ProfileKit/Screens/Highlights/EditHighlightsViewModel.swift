//
//  EditHighlightsViewModel.swift
//  ProfileKit
//
//  Created by Findlay Wood on 04/10/2026.
//

import Combine
import Foundation

/// Choosing the PB tiles (`PROFILE_PLAN.md` step 8): pick up to three of your
/// logged exercises, in the order picked, or none for **Automatic**, your
/// three most-trained.
///
/// **Save reports the result as it will look**, worked out here from the
/// candidates already on screen: the picks in order, or the top three
/// candidates for Automatic, since candidates are ordered by sets exactly as
/// the server ranks them. The server takes a few seconds to rebuild
/// `ProfileHighlights`, and the profile should not show the old tiles
/// meanwhile.
///
/// A fourth pick is refused rather than replacing the oldest. Swapping one out
/// silently would change a choice the user can no longer see.
@MainActor
final class EditHighlightsViewModel: ObservableObject {

    enum LoadState: Equatable {
        case loading
        case loaded
        case failed
    }

    static let candidateLimit = 50

    @Published private(set) var loadState: LoadState = .loading
    @Published private(set) var candidates: [ProfileHighlight] = []
    @Published private(set) var selection: [String]
    @Published private(set) var isSaving = false
    @Published private(set) var errorMessage: String?

    private let originalSelection: [String]
    private let loader: HighlightCandidatesLoader
    private let writer: PinnedHighlightsWriter

    var onSaved: ((ProfileHighlights) -> Void)?
    var onFinished: (() -> Void)?

    /// `pinned` is the current choice, empty when highlights are automatic.
    init(pinned: [String], loader: HighlightCandidatesLoader, writer: PinnedHighlightsWriter) {
        self.selection = pinned
        self.originalSelection = pinned
        self.loader = loader
        self.writer = writer
    }

    var isAutomatic: Bool { selection.isEmpty }
    var hasChanges: Bool { selection != originalSelection }

    func position(of exerciseId: String) -> Int? {
        selection.firstIndex(of: exerciseId).map { $0 + 1 }
    }

    func load() async {
        loadState = .loading
        do {
            candidates = try await loader.candidates(limit: Self.candidateLimit)
            // A pin whose stats are gone cannot be shown; drop it now so the
            // count of picks matches what is on screen.
            let known = Set(candidates.map(\.exerciseId))
            selection = selection.filter(known.contains)
            loadState = .loaded
        } catch {
            print("❌ Highlight candidates failed: \(error)")
            loadState = .failed
        }
    }

    func toggle(_ exerciseId: String) {
        errorMessage = nil
        if let index = selection.firstIndex(of: exerciseId) {
            selection.remove(at: index)
        } else if selection.count < ProfileHighlights.limit {
            selection.append(exerciseId)
        }
    }

    func useAutomatic() {
        selection = []
    }

    func cancel() {
        onFinished?()
    }

    func save() async {
        guard !isSaving else { return }
        guard hasChanges else {
            onFinished?()
            return
        }
        isSaving = true
        errorMessage = nil
        defer { isSaving = false }
        do {
            try await writer.setPinned(selection)
            onSaved?(result)
            onFinished?()
        } catch {
            print("❌ Pinned highlights save failed: \(error)")
            errorMessage = "Couldn't save your highlights. Check your connection and try again."
        }
    }

    private var result: ProfileHighlights {
        if selection.isEmpty {
            return ProfileHighlights(highlights: Array(candidates.prefix(ProfileHighlights.limit)), isPinned: false)
        }
        let byId = Dictionary(uniqueKeysWithValues: candidates.map { ($0.exerciseId, $0) })
        return ProfileHighlights(highlights: selection.compactMap { byId[$0] }, isPinned: true)
    }
}
