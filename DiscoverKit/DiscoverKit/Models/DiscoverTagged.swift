//
//  DiscoverTagged.swift
//  DiscoverKit
//
//  Created by Findlay Wood on 30/09/2026.
//

import Foundation

/// A card found under a tag, with how many votes put it there — the ordering
/// of a tag's page. The entry document is the card's projection plus
/// `voteCount`, so the card decodes from the same document and nothing is
/// duplicated between the two models.
public struct DiscoverTagged<Card: Decodable & Identifiable & Hashable & Sendable>: Decodable, Identifiable, Hashable, Sendable where Card.ID == String {
    public let card: Card
    public let voteCount: Int

    public var id: String { card.id }

    public init(card: Card, voteCount: Int) {
        self.card = card
        self.voteCount = voteCount
    }

    private enum CodingKeys: String, CodingKey {
        case voteCount
    }

    public init(from decoder: Decoder) throws {
        self.card = try Card(from: decoder)
        self.voteCount = try decoder.container(keyedBy: CodingKeys.self).decodeIfPresent(Int.self, forKey: .voteCount) ?? 0
    }
}
