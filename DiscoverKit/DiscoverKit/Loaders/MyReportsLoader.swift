//
//  MyReportsLoader.swift
//  DiscoverKit
//
//  Created by Findlay Wood on 30/09/2026.
//

import Foundation

/// Everything the signed-in user has reported — kept hidden from them from the
/// moment they report it, across sessions, whatever anyone else decides.
public protocol MyReportsLoader {
    func reportedTargets() async throws -> Set<DiscoverReportTarget>
}
