//
//  MyBodyVoteLoader.swift
//  DiscoverKit
//
//  Created by Findlay Wood on 25/10/2026.
//

import Foundation

/// The signed-in user's own suggestion on an exercise, if they have made one —
/// so the sheet reopens on what they sent rather than starting over.
public protocol MyBodyVoteLoader {
    func myBodyVote(onExercise exerciseId: String) async throws -> DiscoverBodyVote?
}
