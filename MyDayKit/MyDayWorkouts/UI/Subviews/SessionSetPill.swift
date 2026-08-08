//
//  SessionSetPill.swift
//  MyDayKit
//
//  Created by Findlay Wood on 27/06/2026.
//

import SwiftUI

struct SessionSetPill: View {

    let index: Int
    let set: WorkoutSetModel
    let record: WorkoutSetRecord?

    /// The session is not accepting logs — before it starts, or once finished.
    /// Dims the empty circle so the pill reads as not-actionable, but the pill
    /// stays **tappable**: the detail overlay is worth reading in every state,
    /// to look a set over before starting and to revisit it afterwards.
    let isInactive: Bool

    let matchedId: String
    let animation: Namespace.ID
    let onTap: () -> Void

    /// Logs the set at its prescribed values straight from the pill, skipping
    /// the overlay entirely — the common case is performing a set exactly as
    /// written, and making that cost two taps and a sheet was the whole reason
    /// to add this. `nil` whenever the set cannot be quick-completed (session
    /// not running, session finished, set already logged, or nothing
    /// prescribed to log), and the circle then behaves like the rest of the
    /// pill and opens the overlay.
    var onQuickComplete: (() -> Void)?

    private var isLogged: Bool { record?.isCompleted ?? false }

    private var values: [SessionSetPillValue] {
        SessionSetPillValue.values(for: set, record: record)
    }

    var body: some View {
        VStack(spacing: 4) {
            Text("Set \(index + 1)")
                .font(.system(size: 10, weight: .semibold))
                .foregroundStyle(isLogged ? Color.white.opacity(0.7) : Color.secondary)
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
                .foregroundStyle(colour(at: position))
                .lineLimit(1)
                .minimumScaleFactor(0.7)
            }

            Spacer(minLength: 4)

            Image(systemName: isLogged ? "checkmark.circle.fill" : "circle")
                .font(.system(size: 22, weight: .medium))
                .foregroundStyle(circleColour)
                // Widened past the 22pt glyph so the quick tap is comfortable.
                // Width only: the pill is a fixed 72x88 and a set carrying two
                // values already fills it, so growing this vertically would
                // push the text into the clip.
                .frame(width: 44)
                .contentShape(Rectangle())
                // A tap gesture on a child takes the tap before the ancestor's,
                // so this splits one target out of a pill that is otherwise a
                // single tap area. Falls through to `onTap` when there is
                // nothing to quick-complete, rather than swallowing the tap.
                .onTapGesture { (onQuickComplete ?? onTap)() }
        }
        .frame(width: 72, height: 88)
        .padding(.vertical, 8)
        .background {
            RoundedRectangle(cornerRadius: 14, style: .continuous)
                .matchedGeometryEffect(id: "\(matchedId)background", in: animation)
                .foregroundStyle(isLogged ? Color.darkColor : Color(UIColor.secondarySystemBackground))
                .overlay {
                    RoundedRectangle(cornerRadius: 14, style: .continuous)
                        .inset(by: 0.5)
                        .stroke(Color(UIColor.separator), lineWidth: 0.5)
                        .matchedGeometryEffect(id: "\(matchedId)overlay", in: animation)
                }
        }
        .clipShape(RoundedRectangle(cornerRadius: 14, style: .continuous))
        .contentShape(Rectangle())
        .onTapGesture { onTap() }
        .animation(.easeInOut(duration: 0.2), value: isLogged)
    }

    /// Brand-tinted while the circle is a live control, so it reads as
    /// something to press rather than a status dot — otherwise there is no way
    /// to discover that it does anything the rest of the pill does not.
    private var circleColour: Color {
        if isLogged { return Color.white }
        if onQuickComplete != nil { return Color.darkColor.opacity(0.55) }
        return Color.secondary.opacity(isInactive ? 0.25 : 0.5)
    }

    private func colour(at position: Int) -> Color {
        if isLogged {
            return position == 0 ? Color.white : Color.white.opacity(0.85)
        }
        return position == 0 ? Color.primary : Color.darkColor
    }
}

// MARK: - Preview

#Preview {
    @Previewable @Namespace var animation

    HStack(spacing: 8) {
        SessionSetPill(
            index: 0,
            set: WorkoutSetModel(id: "s1", orderIndex: 0, reps: 8, weight: 80, weightUnit: .kg),
            record: nil,
            isInactive: true,
            matchedId: "e1-s1",
            animation: animation,
            onTap: {}
        )
        SessionSetPill(
            index: 1,
            set: WorkoutSetModel(id: "s2", orderIndex: 1, reps: 8, weight: 80, weightUnit: .kg),
            record: WorkoutSetRecord(id: "s2", isCompleted: true, reps: 6, weight: 85, weightUnit: .kg),
            isInactive: false,
            matchedId: "e1-s2",
            animation: animation,
            onTap: {}
        )
        // Quick-completable: circle tinted, and its tap logs rather than opens.
        SessionSetPill(
            index: 2,
            set: WorkoutSetModel(id: "s3", orderIndex: 2, time: 60, distance: 400, distanceUnit: .metres),
            record: nil,
            isInactive: false,
            matchedId: "e1-s3",
            animation: animation,
            onTap: {},
            onQuickComplete: {}
        )
        SessionSetPill(
            index: 3,
            set: WorkoutSetModel(id: "s4", orderIndex: 3, reps: 12, weightUnit: .bw),
            record: nil,
            isInactive: false,
            matchedId: "e1-s4",
            animation: animation,
            onTap: {}
        )
    }
    .padding(20)
    .background(Color(UIColor.systemGroupedBackground))
}
