//
//  DiscoverSearchQuery.swift
//  DiscoverKit
//
//  Created by Findlay Wood on 05/10/2026.
//

import Foundation

/// **The one definition of what a search actually looks for**, and how a
/// query is compared with a title or a name.
///
/// `normalized` is the query as typed: trimmed, lowercased, a leading "@"
/// dropped — people type usernames the way they see them written. It is what
/// the username prefix range runs on.
///
/// `words` is how a query **and** a title are split for matching by word:
/// lowercased, accents folded ("Café" → "cafe"), split on anything that is not
/// a letter or a digit. **It must stay in step with `searchWords` in the Cloud
/// Functions' `Search/SearchTokens.ts`**, which builds the `searchTokens` the
/// workout and people queries match: a word one side keeps and the other drops
/// is a search that can never match.
///
/// Carried over from ProfileKit's people-only search, which this replaced, and
/// widened when search stopped matching only the start of a title.
public enum DiscoverSearchQuery {

    /// The longest prefix the server stores per word — `MAX_TOKEN_LENGTH` in
    /// `SearchTokens.ts`, and must match it. A longer query word is looked up
    /// by its first `maxTokenLength` characters and checked in full afterwards.
    public static let maxTokenLength = 15

    public static func normalized(_ text: String) -> String {
        var query = text.trimmingCharacters(in: .whitespacesAndNewlines).lowercased()
        if query.hasPrefix("@") { query.removeFirst() }
        return query
    }

    public static func words(_ text: String) -> [String] {
        text.folding(options: .diacriticInsensitive, locale: nil)
            .lowercased()
            .split { !($0.isLetter || $0.isNumber) }
            .map(String.init)
    }

    /// The one token to ask Firestore for: the **longest** query word, as the
    /// most selective, cut to `maxTokenLength`. Firestore allows one
    /// `array-contains` per query, so a multi-word search fetches by this word
    /// and `matches` checks the others.
    public static func lookupToken(for words: [String]) -> String? {
        words.max { $0.count < $1.count }.map { String($0.prefix(maxTokenLength)) }
    }

    /// Whether **every** query word starts some word of the texts — "back sq"
    /// matches "Back Squat", and so does "squat back"; "back squat" does not
    /// match "Back Row".
    public static func matches(_ queryWords: [String], in texts: [String]) -> Bool {
        let textWords = texts.flatMap(words)
        return queryWords.allSatisfy { queryWord in
            textWords.contains { $0.hasPrefix(queryWord) }
        }
    }
}
