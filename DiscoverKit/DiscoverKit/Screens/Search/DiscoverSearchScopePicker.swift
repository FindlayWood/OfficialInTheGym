//
//  DiscoverSearchScopePicker.swift
//  DiscoverKit
//
//  Created by Findlay Wood on 05/10/2026.
//

import SwiftUI

/// The filter under the search field: All, People, Workouts, Exercises, as a
/// row of capsules. The selected one is filled `darkColor` — a selection, as
/// on every selected pill in the app — and the rest are quiet fills, not a
/// system segmented control, which reads as iOS chrome beside the cards.
struct DiscoverSearchScopePicker: View {

    @Binding var scope: DiscoverSearchScope

    var body: some View {
        HStack(spacing: 8) {
            ForEach(DiscoverSearchScope.allCases, id: \.self) { option in
                Button {
                    withAnimation(.easeInOut(duration: 0.15)) { scope = option }
                } label: {
                    Text(option.title)
                        .font(.system(size: 14, weight: .semibold))
                        .foregroundStyle(option == scope ? .white : .primary)
                        .padding(.horizontal, 14)
                        .frame(height: 32)
                        .background(
                            Capsule().fill(option == scope ? Color.darkColor : Color(.tertiarySystemFill))
                        )
                }
                .buttonStyle(.plain)
                .accessibilityAddTraits(option == scope ? .isSelected : [])
            }
            Spacer(minLength: 0)
        }
    }
}
