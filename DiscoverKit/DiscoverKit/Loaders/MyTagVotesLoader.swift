//
//  MyTagVotesLoader.swift
//  DiscoverKit
//
//  Created by Findlay Wood on 30/09/2026.
//

import Foundation

/// The tags the signed-in user has applied to a subject — shown to them at
/// once, marked as theirs, even while too few others agree for the tag to be
/// visible to anyone else.
public protocol MyTagVotesLoader {
    func myTags(on subject: DiscoverSubject) async throws -> [String]
}
