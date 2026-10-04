//
//  ProfileClipsLoader.swift
//  ProfileKit
//
//  Created by Findlay Wood on 04/10/2026.
//
import Foundation

/// Loads a user's newest public, visible clips, the same cards DISCOVER shows,
/// so the profile grid and DISCOVER can never disagree about which clips are
/// public.
public protocol ProfileClipsLoader {
    func clips(of userId: String, limit: Int) async throws -> [ProfileClip]
}
