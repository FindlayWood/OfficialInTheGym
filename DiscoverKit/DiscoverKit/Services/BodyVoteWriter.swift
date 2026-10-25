//
//  BodyVoteWriter.swift
//  DiscoverKit
//
//  Created by Findlay Wood on 25/10/2026.
//

import Foundation

/// Replaces the signed-in user's suggestion on an exercise with `vote`. One
/// document per user holds the whole set, so a user counts once however often
/// they change it.
public protocol BodyVoteWriter {
    func setMyBodyVote(_ vote: DiscoverBodyVote, onExercise exerciseId: String) async throws
}
