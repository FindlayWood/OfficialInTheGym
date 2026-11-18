//
//  MyDayWorkoutBuilderExerciseRow.swift
//  MyDayKit
//
//  Created by Findlay Wood on 18/11/2026.
//

import SwiftUI

/// One exercise in the workout builder's list, with the button that joins it to the next one in a
/// superset.
///
/// **The link button took the drag handle's place.** The handle drew `line.3.horizontal` but the
/// list had no `.onMove`, so it promised a reorder that never happened. The link sits between this
/// exercise and the next in meaning, so it is drawn on every row but the last, filled while joined.
///
/// The leading tile shows the exercise's label ("1a") once the workout has a superset, and the
/// dumbbell otherwise, so a workout without supersets is built exactly as before.
struct MyDayWorkoutBuilderExerciseRow: View {

    let name: String
    let entry: WorkoutSupersetLayout.Entry?
    let isLinkedToNext: Bool
    let canLink: Bool
    let onToggleLink: () -> Void

    var body: some View {
        HStack(spacing: 12) {
            leadingTile

            Text(name)
                .font(.system(size: 16, weight: .medium))

            Spacer()

            if canLink {
                Button(action: onToggleLink) {
                    Image(systemName: "link")
                        .font(.system(size: 13, weight: .semibold))
                        .foregroundStyle(isLinkedToNext ? Color.white : Color.secondary)
                        .frame(width: 32, height: 32)
                        .background(
                            Circle().fill(isLinkedToNext ? Color.darkColor : Color(.tertiarySystemFill))
                        )
                        .frame(width: 44, height: 44)
                        .contentShape(Rectangle())
                }
                .buttonStyle(.plain)
                .accessibilityLabel(isLinkedToNext ? "Unlink from the next exercise" : "Superset with the next exercise")
            }
        }
        .padding(.vertical, 4)
    }

    @ViewBuilder
    private var leadingTile: some View {
        if let entry {
            Text(entry.label)
                .font(.system(size: 13, weight: .bold))
                .foregroundStyle(entry.position.isInSuperset ? Color.white : Color.darkColor)
                .lineLimit(1)
                .minimumScaleFactor(0.7)
                .frame(width: 32, height: 32)
                .background(
                    RoundedRectangle(cornerRadius: 6, style: .continuous)
                        .fill(entry.position.isInSuperset ? Color.darkColor : Color.darkColor.opacity(0.12))
                )
        } else {
            RoundedRectangle(cornerRadius: 6, style: .continuous)
                .fill(Color.darkColor.opacity(0.12))
                .frame(width: 32, height: 32)
                .overlay(
                    Image(systemName: "dumbbell.fill")
                        .font(.system(size: 13, weight: .medium))
                        .foregroundColor(Color.darkColor)
                )
        }
    }
}
