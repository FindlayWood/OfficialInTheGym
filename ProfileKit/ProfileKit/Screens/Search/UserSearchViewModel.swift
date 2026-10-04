//
//  UserSearchViewModel.swift
//  ProfileKit
//
//  Created by Findlay Wood on 04/10/2026.
//

import Combine
import Foundation

/// Finding people by @username or display name (`PROFILE_PLAN.md` step 7).
///
/// **Debounced, and every keystroke cancels the search before it.** Without
/// cancelling, a slow early search ("a") can land after a fast later one
/// ("alex") and replace the right results with the wrong ones. The debounce
/// keeps one query per pause rather than one per letter.
///
/// The query is normalised once, here: trimmed, lowercased, a leading "@"
/// dropped (people type usernames the way they see them written). It is then
/// matched against the `usernameLower` / `displayNameLower` fields
/// `syncProfile` writes.
@MainActor
final class UserSearchViewModel: ObservableObject {

    enum State: Equatable {
        case idle
        case searching
        case results([ProfileSummary])
        case failed
    }

    static let limit = 20

    @Published var query = "" {
        didSet { scheduleSearch() }
    }
    @Published private(set) var state: State = .idle

    private let loader: UserSearchLoader
    private let debounce: Duration
    private var searchTask: Task<Void, Never>?

    init(loader: UserSearchLoader, debounce: Duration = .milliseconds(300)) {
        self.loader = loader
        self.debounce = debounce
    }

    static func normalized(_ query: String) -> String {
        var text = query.trimmingCharacters(in: .whitespacesAndNewlines).lowercased()
        if text.hasPrefix("@") { text.removeFirst() }
        return text
    }

    private func scheduleSearch() {
        searchTask?.cancel()
        let text = Self.normalized(query)
        guard !text.isEmpty else {
            state = .idle
            return
        }
        searchTask = Task { [weak self, debounce] in
            try? await Task.sleep(for: debounce)
            guard !Task.isCancelled else { return }
            await self?.search(text)
        }
    }

    /// Runs one search now. The debounced path calls this; tests call it
    /// directly.
    func search(_ text: String) async {
        state = .searching
        do {
            let results = try await loader.search(text, limit: Self.limit)
            guard !Task.isCancelled, Self.normalized(query) == text else { return }
            state = .results(results)
        } catch {
            guard !Task.isCancelled else { return }
            print("❌ User search failed: \(error)")
            state = .failed
        }
    }
}
