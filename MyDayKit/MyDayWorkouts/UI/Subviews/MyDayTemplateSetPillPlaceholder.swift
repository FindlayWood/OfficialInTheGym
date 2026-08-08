//
//  MyDayTemplateSetPillPlaceholder.swift
//  MyDayKit
//
//  Created by Findlay Wood on 08/08/2026.
//

import SwiftUI

/// Holds the layout slot in the template card's sets row while its
/// `MyDayTemplateSetPill` is flying up into `SessionSetDetailOverlay`. Carries
/// no matched geometry of its own, but mirrors the pill's size and values so
/// the slot it leaves behind is the same size.
///
/// **It must read its values from `SessionSetPillValue` exactly as the pill
/// does** — rendering a different set of measures would resize the slot
/// mid-flight and the hero would land crooked.
struct MyDayTemplateSetPillPlaceholder: View {

    let index: Int
    let set: WorkoutSetModel

    private var values: [SessionSetPillValue] {
        SessionSetPillValue.values(for: set, record: nil)
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
    MyDayTemplateSetPillPlaceholder(
        index: 0,
        set: WorkoutSetModel(id: "s1", orderIndex: 0, reps: 8, weight: 80, weightUnit: .kg)
    )
    .padding(20)
    .background(Color.white)
}
