//
//  BalanceCondition.swift
//  PerformanceKit
//
//  Created by Findlay Wood on 10/10/2026.
//
import Foundation

/// Whether a balance test is done with eyes open or closed. Closed takes
/// vision away and leaves balance to the inner ear and the feet, which is the
/// harder and more telling test. A session is one condition throughout, since
/// sways under the two are not comparable. `rawValue` is stored.
public enum BalanceCondition: String, Sendable, CaseIterable {
    case eyesOpen
    case eyesClosed

    var title: String {
        switch self {
        case .eyesOpen: "Eyes open"
        case .eyesClosed: "Eyes closed"
        }
    }
}
