//
//  ExerciseClipsLoader.swift
//  DiscoverKit
//
//  Created by Findlay Wood on 02/10/2026.
//

import Foundation

/// The newest public clips of one exercise — a clip is a user doing an
/// exercise, so its exercise's page is where it is found.
public protocol ExerciseClipsLoader {
    func clips(ofExercise exerciseId: String, limit: Int) async throws -> [DiscoverClipCard]
}
