//
//  PerformanceSectionHeader.swift
//  PerformanceKit
//
//  Created by Findlay Wood on 10/10/2026.
//
import SwiftUI

/// A section's uppercase caption, above its card. The caption style of
/// `ProfileSettingsSection` and `AccountCreationFieldCard`.
struct PerformanceSectionHeader: View {

    let title: String

    var body: some View {
        Text(title)
            .font(.system(size: 13, weight: .semibold))
            .foregroundStyle(Color.secondary)
            .textCase(.uppercase)
            .tracking(0.8)
            .frame(maxWidth: .infinity, alignment: .leading)
            .padding(.horizontal, 4)
    }
}
