//
//  MyRatingLoader.swift
//  DiscoverKit
//
//  Created by Findlay Wood on 30/09/2026.
//

import Foundation

/// The signed-in user's own rating of a subject, or `nil` if they have not
/// rated it. The adapter knows who is signed in; the framework never sees a
/// user id for this.
public protocol MyRatingLoader {
    func myRating(for subject: DiscoverSubject) async throws -> Int?
}
