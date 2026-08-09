//
//  WorkoutSessionFinishBar.swift
//  MyDayKit
//
//  Created by Findlay Wood on 04/08/2026.
//

import SwiftUI

/// Pinned bottom action for an in-progress session. Takes the slot
/// `WorkoutSessionStartCard` occupies before the session starts — start at the
/// bottom, finish at the bottom — and matches its button styling, which is why
/// the metrics here are duplicated rather than shared.
struct WorkoutSessionFinishBar: View {

    /// False until at least one set has been logged. A session with nothing
    /// performed has nothing to finish — it would write a completed session
    /// holding no work, counting toward stats and, once assignment ships,
    /// telling a coach the workout was done.
    var isEnabled: Bool = true

    var onFinish: (() -> Void)?

    var body: some View {
        VStack(spacing: 0) {
            Divider()

            Button {
                onFinish?()
            } label: {
                Text("Finish Workout")
                    .font(.system(size: 17, weight: .semibold))
                    .foregroundStyle(isEnabled ? Color.white : Color.secondary)
                    .frame(maxWidth: .infinity)
                    .padding(.vertical, 16)
                    .background(
                        RoundedRectangle(cornerRadius: 16, style: .continuous)
                            .fill(isEnabled ? Color.darkColor : Color(UIColor.tertiarySystemFill))
                    )
            }
            .buttonStyle(.plain)
            .disabled(!isEnabled)
            .animation(.easeInOut(duration: 0.15), value: isEnabled)
            .padding(.horizontal, 20)
            .padding(.vertical, 12)
        }
        .background(Color.white.ignoresSafeArea(edges: .bottom))
    }
}

// MARK: - Preview

#Preview {
    ZStack(alignment: .bottom) {
        Color.darkColor.ignoresSafeArea()
        WorkoutSessionFinishBar()
    }
}
