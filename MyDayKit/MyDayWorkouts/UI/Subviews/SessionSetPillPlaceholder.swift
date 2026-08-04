//
//  SessionSetPillPlaceholder.swift
//  MyDayKit
//
//  Created by Findlay Wood on 01/08/2026.
//

import SwiftUI

/// Holds the layout slot in the sets row while its `SessionSetPill` is flying
/// up into `SessionSetDetailOverlay`. Carries no matched geometry of its own,
/// but mirrors the pill's values so the slot it leaves behind is the same size.
struct SessionSetPillPlaceholder: View {

    let index: Int
    let set: WorkoutSetModel
    let record: WorkoutSetRecord?

    private var values: [SessionSetPillValue] {
        SessionSetPillValue.values(for: set, record: record)
    }

    var body: some View {
        VStack(spacing: 4) {
            Text("Set \(index + 1)")
                .font(.system(size: 10, weight: .semibold))
                .foregroundStyle(Color.secondary)
                .textCase(.uppercase)
                .tracking(0.5)

            ForEach(Array(values.enumerated()), id: \.element.id) { position, value in
                HStack(alignment: .lastTextBaseline, spacing: 2) {
                    Text(value.value)
                        .font(.system(size: position == 0 ? 16 : 12, weight: position == 0 ? .bold : .semibold))
                    if let unit = value.unit {
                        Text(unit)
                            .font(.system(size: 10))
                    }
                }
                .foregroundStyle(Color.primary)
                .lineLimit(1)
                .minimumScaleFactor(0.7)
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
        set: WorkoutSetModel(id: "s1", orderIndex: 0, reps: 8, weight: 80, weightUnit: .kg),
        record: nil
    )
    .padding(20)
    .background(Color(UIColor.systemGroupedBackground))
}
