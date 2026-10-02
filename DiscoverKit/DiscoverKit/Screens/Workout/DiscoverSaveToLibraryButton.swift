//
//  DiscoverSaveToLibraryButton.swift
//  DiscoverKit
//
//  Created by Findlay Wood on 02/10/2026.
//

import SwiftUI

/// The workout page's one action: a full-width 52pt button, the same as every
/// MyDay builder screen's forward action. Once saved it settles into the gated
/// look with a check — done, and not something to press again.
struct DiscoverSaveToLibraryButton: View {

    let state: DiscoverWorkoutSaveState
    let action: () -> Void

    var body: some View {
        VStack(spacing: 8) {
            Button(action: action) {
                HStack(spacing: 8) {
                    switch state {
                    case .saving, .checking:
                        ProgressView().tint(isActionable ? .white : .secondary)
                    case .saved:
                        Image(systemName: "checkmark")
                            .font(.system(size: 15, weight: .bold))
                    default:
                        Image(systemName: "square.and.arrow.down")
                            .font(.system(size: 15, weight: .semibold))
                    }
                    Text(state == .saved ? "Saved to Library" : "Save to Library")
                        .font(.system(size: 16, weight: .semibold))
                }
                .foregroundStyle(isActionable ? .white : Color.secondary)
                .frame(maxWidth: .infinity)
                .frame(height: 52)
                .background(
                    RoundedRectangle(cornerRadius: 14)
                        .fill(isActionable ? Color.darkColor : Color(UIColor.tertiarySystemFill))
                )
            }
            .buttonStyle(.plain)
            .disabled(!isActionable)
            .animation(.easeInOut(duration: 0.15), value: state)

            if state == .failed {
                Text("Couldn't save. Try again.")
                    .font(.system(size: 13))
                    .foregroundStyle(.white.opacity(0.8))
            } else if state == .saved {
                Text("It's in your library in MyDay — add it to a day from there.")
                    .font(.system(size: 13))
                    .foregroundStyle(.white.opacity(0.8))
                    .multilineTextAlignment(.center)
            }
        }
    }

    private var isActionable: Bool {
        state == .idle || state == .failed
    }
}
