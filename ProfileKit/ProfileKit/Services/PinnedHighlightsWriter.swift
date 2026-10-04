//
//  PinnedHighlightsWriter.swift
//  ProfileKit
//
//  Created by Findlay Wood on 04/10/2026.
//
import Foundation

/// Saves which exercises the signed-in user pins as highlights, in order, at
/// most three. An empty list goes back to automatic. The server rebuilds
/// `ProfileHighlights` from it.
public protocol PinnedHighlightsWriter {
    func setPinned(_ exerciseIds: [String]) async throws
}
