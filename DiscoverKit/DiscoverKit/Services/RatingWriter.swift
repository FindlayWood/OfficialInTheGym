//
//  RatingWriter.swift
//  DiscoverKit
//
//  Created by Findlay Wood on 30/09/2026.
//

import Foundation

/// Sets the signed-in user's rating of a subject, 1–10.
///
/// There is one rating per user per subject — the document's id is the user's
/// id — so rating again **replaces** the earlier rating rather than adding a
/// second one. There is no delete: a rating can be changed, not withdrawn.
public protocol RatingWriter {
    func setRating(_ rating: Int, for subject: DiscoverSubject) async throws
}
