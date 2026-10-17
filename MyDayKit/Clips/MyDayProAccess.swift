//
//  MyDayProAccess.swift
//  MyDayKit
//
//  Created by Findlay Wood on 12/10/2026.
//

import Foundation

/// Whether the signed-in user has INTHEGYM pro, which recording and watching clips require.
///
/// Read at the moment a clip is recorded or opened (`MyDayFullScreenCover.requiresPro`), never
/// captured when the coordinator is built, so someone who subscribes from the paywall can tap the
/// same button straight after. Logging itself is free; only clips are pro.
public protocol MyDayProAccess {
    var hasUnlockedPro: Bool { get }
}
