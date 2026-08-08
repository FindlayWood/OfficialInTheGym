//
//  MyDayTemplateSetPill.swift
//  MyDayKit
//
//  Created by Findlay Wood on 27/06/2026.
//

import SwiftUI

/// One prescribed set on the workout template detail screen.
///
/// Values come from `SessionSetPillValue.values(for:record:)` with no record —
/// the template is pure prescription — so this pill caps at **two values** in
/// the same priority order as every other set pill. It previously rendered
/// reps, weight, time and distance unconditionally into a fixed 72×72 frame,
/// so a set carrying all four overflowed and its text spilled out of the card.
/// **Do not lay this out to fit whatever the set happens to hold.**
///
/// Tapping opens `SessionSetDetailOverlay` in `.planned` mode, which is exactly
/// this screen's question: what does this set ask me to do? Keep in step with
/// `SessionSetPill`.
struct MyDayTemplateSetPill: View {

    let index: Int
    let set: WorkoutSetModel
    let matchedId: String
    let animation: Namespace.ID
    var onTap: (() -> Void)?

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
                .foregroundStyle(position == 0 ? Color.primary : Color.darkColor)
                .lineLimit(1)
                .minimumScaleFactor(0.7)
            }

            Spacer(minLength: 4)

            // The dimmed circle a `.planned` `SessionSetPill` draws. A template
            // set has not been performed, so the empty state is the honest one,
            // and it fills the slot that would otherwise leave these pills
            // looking lopsided next to every other 72×88 pill in the app.
            // Indicator only — the whole pill is the tap target.
            Image(systemName: "circle")
                .font(.system(size: 22, weight: .medium))
                .foregroundStyle(Color.secondary.opacity(0.25))
        }
        .frame(width: 72, height: 88)
        .padding(.vertical, 8)
        .background {
            RoundedRectangle(cornerRadius: 14, style: .continuous)
                .matchedGeometryEffect(id: "\(matchedId)background", in: animation)
                .foregroundStyle(Color(UIColor.secondarySystemBackground))
                .overlay {
                    RoundedRectangle(cornerRadius: 14, style: .continuous)
                        .inset(by: 0.5)
                        .stroke(Color(UIColor.separator), lineWidth: 0.5)
                        .matchedGeometryEffect(id: "\(matchedId)overlay", in: animation)
                }
        }
        .clipShape(RoundedRectangle(cornerRadius: 14, style: .continuous))
        .contentShape(Rectangle())
        .onTapGesture { onTap?() }
    }
}

// MARK: - Preview

#Preview {
    @Previewable @Namespace var animation

    HStack(spacing: 8) {
        MyDayTemplateSetPill(
            index: 0,
            set: WorkoutSetModel(id: "s1", orderIndex: 0, reps: 8, weight: 80, weightUnit: .kg),
            matchedId: "e1-s1",
            animation: animation
        )
        MyDayTemplateSetPill(
            index: 1,
            set: WorkoutSetModel(id: "s2", orderIndex: 1, time: 60),
            matchedId: "e1-s2",
            animation: animation
        )
        // All four measures — capped to two rather than spilling out the card.
        MyDayTemplateSetPill(
            index: 2,
            set: WorkoutSetModel(
                id: "s3",
                orderIndex: 2,
                reps: 12,
                weight: 20,
                weightUnit: .kg,
                time: 45,
                distance: 400,
                distanceUnit: .metres
            ),
            matchedId: "e1-s3",
            animation: animation
        )
    }
    .padding(20)
    .background(Color.white)
}
