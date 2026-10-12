//
//  DiscoverProAccess.swift
//  DiscoverKit
//
//  Created by Findlay Wood on 12/10/2026.
//

import Foundation

/// Whether the signed-in user has INTHEGYM pro, which watching a clip requires.
///
/// Read at the moment a clip is opened (`DiscoverKitRoutes.requiresPro`), never captured when the
/// router is built, so someone who subscribes from the paywall can tap the same clip straight
/// after. Everything else on DISCOVER is free, and clips stay **visible** without pro — the
/// thumbnails are the advert; playing one is the product.
public protocol DiscoverProAccess {
    var hasUnlockedPro: Bool { get }
}
