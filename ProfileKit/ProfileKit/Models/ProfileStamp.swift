//
//  ProfileStamp.swift
//  ProfileKit
//
//  Created by Findlay Wood on 03/10/2026.
//

import SwiftUI

/// A badge beside the display name. The legacy header drew the same three, in
/// the same order, as `UserStampsView`.
///
/// `stamps(for:hasUnlockedPro:)` is **the one place the rule is written**:
/// elite and verified come from the profile, and premium comes only from the
/// subscription service, which can answer for the signed-in user and no one else.
/// So **premium is passed in only for your own profile.** When other users'
/// profiles arrive (step 7), they must pass `false` rather than guess. A crown
/// that shows on some screens and not others is worse than none (see
/// `PROFILE_PLAN.md`, open question 3).
enum ProfileStamp: CaseIterable, Identifiable {
    case elite
    case verified
    case premium

    var id: Self { self }

    static func stamps(for header: ProfileHeader, hasUnlockedPro: Bool) -> [ProfileStamp] {
        allCases.filter {
            switch $0 {
            case .elite: header.isElite
            case .verified: header.isVerified
            case .premium: hasUnlockedPro
            }
        }
    }

    var systemImage: String {
        switch self {
        case .elite, .verified: "checkmark.seal.fill"
        case .premium: "crown.fill"
        }
    }

    /// Semantic colours. Each identifies a kind of stamp, so they are not brand
    /// accents and the "no system blue" rule does not apply.
    var color: Color {
        switch self {
        case .elite: .eliteColor
        case .verified: .lightColor
        case .premium: .premiumColor
        }
    }

    var accessibilityLabel: String {
        switch self {
        case .elite: "Elite account"
        case .verified: "Verified account"
        case .premium: "INTHEGYM pro"
        }
    }
}
