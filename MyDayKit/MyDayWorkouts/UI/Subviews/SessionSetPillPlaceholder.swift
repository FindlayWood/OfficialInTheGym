//
//  SessionSetPillPlaceholder.swift
//  MyDayKit
//
//  Created by Findlay Wood on 01/08/2026.
//

import SwiftUI

/// Holds the layout slot in the sets row while its `SessionSetPill` is flying
/// up into `SessionSetDetailOverlay`. Carries no matched geometry of its own.
struct SessionSetPillPlaceholder: View {

    let index: Int
    let set: WorkoutSetModel

    var body: some View {
        VStack(spacing: 4) {
            Text("Set \(index + 1)")
                .font(.system(size: 10, weight: .semibold))
                .foregroundStyle(Color.secondary)
                .textCase(.uppercase)
                .tracking(0.5)

            if let reps = set.reps {
                HStack(alignment: .lastTextBaseline, spacing: 2) {
                    Text("\(reps)")
                        .font(.system(size: 16, weight: .bold))
                    Text("reps")
                        .font(.system(size: 10))
                }
                .foregroundStyle(Color.primary)
            }

            Spacer(minLength: 4)
        }
        .frame(width: 72, height: 88)
        .padding(.vertical, 8)
        .opacity(0.35)
        .background {
            RoundedRectangle(cornerRadius: 14, style: .continuous)
                .fill(Color(UIColor.secondarySystemBackground).opacity(0.5))
        }
        .clipShape(RoundedRectangle(cornerRadius: 14, style: .continuous))
    }
}

// MARK: - Preview

#Preview {
    SessionSetPillPlaceholder(
        index: 0,
        set: WorkoutSetModel(id: "s1", orderIndex: 0, reps: 8, weight: 80, weightUnit: .kg)
    )
    .padding(20)
    .background(Color(UIColor.systemGroupedBackground))
}
