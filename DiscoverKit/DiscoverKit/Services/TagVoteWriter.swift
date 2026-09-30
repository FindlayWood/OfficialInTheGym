//
//  TagVoteWriter.swift
//  DiscoverKit
//
//  Created by Findlay Wood on 30/09/2026.
//

import Foundation

/// Replaces the signed-in user's tags on a subject with `tags`. One document
/// per user holds the whole set, so a user counts once per tag however often
/// they change it, and an empty set withdraws them entirely.
public protocol TagVoteWriter {
    func setMyTags(_ tags: [String], on subject: DiscoverSubject) async throws
}
