//
//  HighlightCandidatesLoader.swift
//  ProfileKit
//
//  Created by Findlay Wood on 04/10/2026.
//
import Foundation

/// The signed-in user's logged exercises with their bests, most-trained first,
/// to choose highlights from. Only the owner can read their own
/// `ExerciseStats`, so this is never asked about anyone else.
public protocol HighlightCandidatesLoader {
    func candidates(limit: Int) async throws -> [ProfileHighlight]
}
