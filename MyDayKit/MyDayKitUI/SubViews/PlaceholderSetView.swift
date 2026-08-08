//
//  PlaceholderSetView.swift
//  MyDayKit
//
//  Created by Findlay Wood on 19/11/2025.
//

import SwiftUI

/// Holds the layout slot in the sets row while its `CompletedSetView` is flying
/// up into `SetDetailView`. Carries no matched geometry of its own, but mirrors
/// the pill's size and values so the slot it leaves behind is the same size —
/// the same job `SessionSetPillPlaceholder` does on the session screen, and now
/// drawn the same way: dimmed rather than outlined in black.
///
/// **It must read its values from `SessionSetPillValue` exactly as the pill
/// does.** Rendering a different set of measures here would resize the slot
/// mid-flight and the hero would land crooked.
struct PlaceholderSetView: View {

    let index: Int
    let model: ExerciseCompletions

    private var values: [SessionSetPillValue] {
        SessionSetPillValue.values(for: model)
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
    PlaceholderSetView(
        index: 0,
        model: .init(
            id: "1",
            exercise: .pressUps,
            reps: 10,
            weight: 20,
            weightUnit: .kg,
            dateCompleted: .now,
            distance: nil,
            distanceUnits: nil,
            time: nil,
            tempo: nil,
            note: nil,
            eachSide: nil
        )
    )
    .padding(20)
    .background(Color.white)
}
