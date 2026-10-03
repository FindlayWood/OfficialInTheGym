//
//  ProfileSubscriptionServiceSpy.swift
//  ProfileKitTests
//
//  Created by Findlay Wood on 03/10/2026.
//
import Foundation
@testable import ProfileKit

/// Records restores, and can be told what a restore finds. Never asserts — the
/// test does.
final class ProfileSubscriptionServiceSpy: ProfileSubscriptionService, @unchecked Sendable {

    enum Message: Equatable {
        case restorePurchases
    }

    private(set) var receivedMessages: [Message] = []
    var hasUnlockedPro: Bool
    private let restoreFindsPurchase: Bool
    private let error: Error?

    init(hasUnlockedPro: Bool = false, restoreFindsPurchase: Bool = false, error: Error? = nil) {
        self.hasUnlockedPro = hasUnlockedPro
        self.restoreFindsPurchase = restoreFindsPurchase
        self.error = error
    }

    func restorePurchases() async throws {
        receivedMessages.append(.restorePurchases)
        if let error { throw error }
        if restoreFindsPurchase { hasUnlockedPro = true }
    }
}
