//
//  PopularTagsLoader.swift
//  DiscoverKit
//
//  Created by Findlay Wood on 30/09/2026.
//

import Foundation

/// The most-used tags, for the home screen's Tags section.
public protocol PopularTagsLoader {
    func popularTags(limit: Int) async throws -> [DiscoverTag]
}
