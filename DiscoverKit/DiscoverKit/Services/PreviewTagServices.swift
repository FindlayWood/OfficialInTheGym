//
//  PreviewTagServices.swift
//  DiscoverKit
//
//  Created by Findlay Wood on 30/09/2026.
//

import Foundation

/// Preview conformer that accepts every tag vote, and normalises tags the way
/// the app does for the ASCII a preview types.
public final class PreviewTagServices: TagVoteWriter, TagNormalizer, @unchecked Sendable {
    public init() {}

    public let maxLength = 32

    public func setMyTags(_ tags: [String], on subject: DiscoverSubject) async throws {}

    public func normalized(_ raw: String) -> String {
        String(raw.lowercased().filter { ("a"..."z").contains($0) || ("0"..."9").contains($0) }.prefix(maxLength))
    }
}
