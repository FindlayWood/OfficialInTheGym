//
//  DiscoverTaggingViewModel.swift
//  DiscoverKit
//
//  Created by Findlay Wood on 30/09/2026.
//

import Combine
import Foundation

/// A subject's tags on its detail screen, and the user's own votes on them.
///
/// **The user sees their own tags at once**, marked as theirs, even while too
/// few others agree for anyone else to see them — otherwise a vote on a new
/// exercise appears to do nothing at all. Visibility to everyone else is the
/// server's call (base tags, or three voters); the screen never guesses it.
///
/// Votes are the whole set in one document, so every change writes the full
/// list. Each change shows before the write lands and is put back if it fails.
@MainActor
final class DiscoverTaggingViewModel: ObservableObject {

    @Published private(set) var visibleTags: [String]
    @Published private(set) var counts: [String: Int]
    @Published private(set) var myTags: [String] = []
    @Published private(set) var suggestions: [DiscoverTag] = []
    @Published private(set) var didFailToSave = false
    @Published var isSheetPresented = false
    @Published var query = "" {
        didSet {
            let normalized = normalizer.normalized(query)
            if normalized != query { query = normalized }
            scheduleSuggestions()
        }
    }

    /// Must match the server's MAX_TAGS_PER_VOTER.
    static let maxMyTags = 10

    let subject: DiscoverSubject
    let canVote: Bool

    private let normalizer: TagNormalizer
    private let myTagsLoader: MyTagVotesLoader
    private let writer: TagVoteWriter
    private let suggestionLoader: TagSuggestionLoader
    private var suggestionTask: Task<Void, Never>?

    init(
        subject: DiscoverSubject,
        visibleTags: [String],
        counts: [String: Int],
        canVote: Bool,
        normalizer: TagNormalizer,
        myTagsLoader: MyTagVotesLoader,
        writer: TagVoteWriter,
        suggestionLoader: TagSuggestionLoader
    ) {
        self.subject = subject
        self.visibleTags = visibleTags
        self.counts = counts
        self.canVote = canVote
        self.normalizer = normalizer
        self.myTagsLoader = myTagsLoader
        self.writer = writer
        self.suggestionLoader = suggestionLoader
    }

    func load() async {
        guard canVote, let mine = try? await myTagsLoader.myTags(on: subject) else { return }
        myTags = mine
    }

    // MARK: - Display

    func isMine(_ tag: String) -> Bool {
        myTags.contains(tag)
    }

    /// What the detail screen shows: every visible tag, then the user's own
    /// votes that are not visible yet.
    var shownTags: [String] {
        visibleTags + myTags.filter { !visibleTags.contains($0) }
    }

    /// What the sheet offers to vote on: everything with a vote, most first.
    var votableTags: [String] {
        let all = Set(visibleTags).union(myTags).union(counts.keys)
        return all.sorted { (counts[$0] ?? 0, $1) > (counts[$1] ?? 0, $0) }
    }

    var canAddMore: Bool {
        myTags.count < Self.maxMyTags
    }

    // MARK: - Voting

    func toggle(_ tag: String) async {
        if isMine(tag) {
            await save(myTags.filter { $0 != tag }, adjusting: tag, by: -1)
        } else if canAddMore {
            await save(myTags + [tag], adjusting: tag, by: 1)
        }
    }

    /// Adds whatever has been typed, already normalised by `query`'s didSet.
    func addQuery() async {
        let tag = query
        guard !tag.isEmpty, !isMine(tag) else {
            query = ""
            return
        }
        query = ""
        await toggle(tag)
    }

    private func save(_ tags: [String], adjusting tag: String, by delta: Int) async {
        guard canVote else { return }
        let previousTags = myTags
        let previousCounts = counts

        myTags = tags
        counts[tag] = max(0, (counts[tag] ?? 0) + delta)
        didFailToSave = false

        do {
            try await writer.setMyTags(tags, on: subject)
        } catch {
            print("❌ Tag vote failed: \(error)")
            myTags = previousTags
            counts = previousCounts
            didFailToSave = true
        }
    }

    // MARK: - Suggestions

    /// Waits for typing to pause before asking — a read per keystroke is a
    /// read per letter of every tag anyone types.
    private func scheduleSuggestions() {
        suggestionTask?.cancel()
        let prefix = query
        guard !prefix.isEmpty else {
            suggestions = []
            return
        }
        suggestionTask = Task { [weak self] in
            try? await Task.sleep(nanoseconds: 250_000_000)
            guard !Task.isCancelled, let self else { return }
            let found = (try? await self.suggestionLoader.tags(startingWith: prefix, limit: 8)) ?? []
            guard !Task.isCancelled else { return }
            self.suggestions = found.filter { $0.tag != prefix && !self.isMine($0.tag) }
        }
    }
}
