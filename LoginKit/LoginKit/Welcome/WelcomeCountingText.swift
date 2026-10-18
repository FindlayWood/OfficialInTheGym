//
//  WelcomeCountingText.swift
//  LoginKit
//
//  Created by Findlay Wood on 18/10/2026.
//

import SwiftUI

/// A whole number that counts through every value on its way to a new one, rather than swapping
/// or rolling digits — the readiness miniature's percentage climbing from 0 as its ring fills.
/// Animating `value` animates the count; the curve is whatever animation drives it.
struct WelcomeCountingText: View, Animatable {

    var value: Double
    var suffix: String = ""

    var animatableData: Double {
        get { value }
        set { value = newValue }
    }

    var body: some View {
        Text("\(Int(value.rounded()))\(suffix)")
            .monospacedDigit()
    }
}
