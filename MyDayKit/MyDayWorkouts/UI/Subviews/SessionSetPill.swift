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
    let isDisabled: Bool
    let matchedId: String
    let animation: Namespace.ID
    let onTap: () -> Void

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
                .foregroundStyle(isLogged ? Color.white : Color.secondary.opacity(isDisabled ? 0.25 : 0.5))
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
        .onTapGesture { if !isDisabled { onTap() } }
        .animation(.easeInOut(duration: 0.2), value: isLogged)
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
            isDisabled: true,
            matchedId: "e1-s1",
            animation: animation,
            onTap: {}
        )
        SessionSetPill(
            index: 1,
            set: WorkoutSetModel(id: "s2", orderIndex: 1, reps: 8, weight: 80, weightUnit: .kg),
            record: WorkoutSetRecord(id: "s2", isCompleted: true, reps: 6, weight: 85, weightUnit: .kg),
            isDisabled: false,
            matchedId: "e1-s2",
            animation: animation,
            onTap: {}
        )
        SessionSetPill(
            index: 2,
            set: WorkoutSetModel(id: "s3", orderIndex: 2, time: 60, distance: 400, distanceUnit: .metres),
            record: nil,
            isDisabled: false,
            matchedId: "e1-s3",
            animation: animation,
            onTap: {}
        )
        SessionSetPill(
            index: 3,
            set: WorkoutSetModel(id: "s4", orderIndex: 3, reps: 12, weightUnit: .bw),
            record: nil,
            isDisabled: false,
            matchedId: "e1-s4",
            animation: animation,
            onTap: {}
        )
    }
    .padding(20)
    .background(Color(UIColor.systemGroupedBackground))
}
