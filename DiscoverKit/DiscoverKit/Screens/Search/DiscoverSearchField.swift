//
//  DiscoverSearchField.swift
//  DiscoverKit
//
//  Created by Findlay Wood on 05/10/2026.
//

import SwiftUI

/// The search field. `DiscoverSearchScreen` puts it on a white bar above the
/// `darkColor` page — the same white-over-dark the home screen's title bar
/// draws, so pushing into search keeps the frame. Autocapitalisation and autocorrect are off: usernames are
/// lowercase, and correcting "deadlift" to something else finds nothing.
struct DiscoverSearchField: View {

    @Binding var text: String
    @FocusState.Binding var isFocused: Bool

    var body: some View {
        HStack(spacing: 10) {
            Image(systemName: "magnifyingglass")
                .font(.system(size: 15, weight: .semibold))
                .foregroundStyle(.secondary)
            TextField("People, workouts, exercises", text: $text)
                .font(.system(size: 16))
                .tint(Color.darkColor)
                .textInputAutocapitalization(.never)
                .autocorrectionDisabled()
                .submitLabel(.search)
                .focused($isFocused)
            if !text.isEmpty {
                Button {
                    text = ""
                } label: {
                    Image(systemName: "xmark.circle.fill")
                        .foregroundStyle(Color(.tertiaryLabel))
                }
                .accessibilityLabel("Clear search")
            }
        }
        .padding(.horizontal, 12)
        .frame(height: 44)
        .background(
            RoundedRectangle(cornerRadius: 12, style: .continuous)
                .fill(Color(.secondarySystemBackground))
        )
    }
}
