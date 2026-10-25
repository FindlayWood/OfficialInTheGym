//
//  DiscoverExerciseMatcher.swift
//  DiscoverKit
//
//  Created by Findlay Wood on 10/10/2026.
//

import Foundation

/// Matches a query against exercise names **on the device**, which is what
/// lets exercise search do what Firestore cannot: find a word from its middle
/// ("quat" → Squat) and forgive a typo ("sqaut" → Squat). The exercise
/// catalogue is small and only changes when it is curated, so the whole of it
/// is loaded once (`CatalogueExerciseSearchLoader`) and searched here.
/// Workouts and people keep growing, so they stay on the server's
/// word-prefix tokens instead.
///
/// Every query word must match some word of the name, scored by how closely:
/// **the start of a word (0) beats inside a word (1) beats one typo away
/// (2)**. A typo is one edit — an insertion, deletion, substitution, or two
/// neighbouring letters swapped — and is only allowed for query words of four
/// or more letters; at three, one edit away from almost anything is something
/// else ("row" → "rot", "raw"), and a short word mistyped is quicker to retype.
///
/// Results are ordered by total score, then by whether the name starts with
/// the first query word ("Bench Press" before "Incline Bench Press" for
/// "bench"), then shorter names, then alphabetically — a fixed order, so the
/// list does not reshuffle between keystrokes that score the same.
///
/// **Public, and the one exercise-name matcher in the app.** MyDay's custom
/// exercise form asks "did you mean…?" through its own `SimilarExerciseFinder`,
/// which the composition root answers with this — so a name that DISCOVER's
/// search would find is exactly a name the form warns about.
public enum DiscoverExerciseMatcher {

    static let typoMinimumLength = 4

    static func search(
        _ query: String,
        in exercises: [DiscoverExerciseCard],
        limit: Int
    ) -> [DiscoverExerciseCard] {
        search(query, in: exercises, name: \.name, limit: limit)
    }

    /// The items whose name matches `query`, best first, at most `limit`.
    public static func search<Item>(
        _ query: String,
        in items: [Item],
        name: (Item) -> String,
        limit: Int
    ) -> [Item] {
        let queryWords = DiscoverSearchQuery.words(query)
        guard !queryWords.isEmpty else { return [] }
        let scored: [(item: Item, name: String, score: Int, leads: Bool)] = items.compactMap { item in
            let itemName = name(item)
            let nameWords = DiscoverSearchQuery.words(itemName)
            guard let score = score(queryWords, against: nameWords) else { return nil }
            return (item, itemName, score, nameWords.first?.hasPrefix(queryWords[0]) ?? false)
        }
        return scored
            .sorted { lhs, rhs in
                if lhs.score != rhs.score { return lhs.score < rhs.score }
                if lhs.leads != rhs.leads { return lhs.leads }
                if lhs.name.count != rhs.name.count { return lhs.name.count < rhs.name.count }
                return lhs.name.localizedCaseInsensitiveCompare(rhs.name) == .orderedAscending
            }
            .prefix(limit)
            .map(\.item)
    }

    /// The total score, or nil if any query word matches nothing.
    static func score(_ queryWords: [String], against nameWords: [String]) -> Int? {
        var total = 0
        for queryWord in queryWords {
            guard let best = nameWords.compactMap({ score(queryWord, against: $0) }).min() else { return nil }
            total += best
        }
        return total
    }

    private static func score(_ queryWord: String, against nameWord: String) -> Int? {
        if nameWord.hasPrefix(queryWord) { return 0 }
        if nameWord.contains(queryWord) { return 1 }
        guard queryWord.count >= typoMinimumLength else { return nil }
        // Compared against the name word cut to the query's length too, so a
        // mistyped *start* ("benc" for "bench", "sqau" for "squat") still counts.
        let start = String(nameWord.prefix(queryWord.count))
        if editDistance(queryWord, start) <= 1 || editDistance(queryWord, nameWord) <= 1 { return 2 }
        return nil
    }

    /// Optimal string alignment distance: Levenshtein, plus a swap of two
    /// neighbouring letters counting as one edit — the commonest typo, which
    /// plain Levenshtein would count as two and so reject.
    static func editDistance(_ a: String, _ b: String) -> Int {
        let a = Array(a), b = Array(b)
        if a.isEmpty { return b.count }
        if b.isEmpty { return a.count }
        var d = (0...a.count).map { i in (0...b.count).map { j in i == 0 ? j : (j == 0 ? i : 0) } }
        for i in 1...a.count {
            for j in 1...b.count {
                let cost = a[i - 1] == b[j - 1] ? 0 : 1
                d[i][j] = min(d[i - 1][j] + 1, d[i][j - 1] + 1, d[i - 1][j - 1] + cost)
                if i > 1, j > 1, a[i - 1] == b[j - 2], a[i - 2] == b[j - 1] {
                    d[i][j] = min(d[i][j], d[i - 2][j - 2] + 1)
                }
            }
        }
        return d[a.count][b.count]
    }
}
