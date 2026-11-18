//
//  MyDayWorkoutBuilderExerciseCard.swift
//  MyDayKit
//
//  Created by Findlay Wood on 18/11/2026.
//

import SwiftUI

/// One exercise in the workout builder, drawn as the card it will be on the workout page: the
/// name over its set count, then its set pills (`MyDayTemplateSetPill`, from the same
/// `setModel(orderIndex:id:)` the saved template uses). Building and reading a workout look alike.
///
/// It replaced a plain list row. **A card in a superset loses the rounded corners it shares with
/// its partner** (`joinsPrevious` / `joinsNext`), so a superset reads as one card cut by a seam,
/// with `MyDayWorkoutBuilderLinkJoint` on the seam. Removing is the `xmark`, since cards in a
/// stack have no swipe-to-delete.
struct MyDayWorkoutBuilderExerciseCard: View {

    @ObservedObject var exercise: WorkoutExerciseBuilderManager
    /// "1a" once the workout has a superset; `nil` draws the dumbbell tile.
    let supersetEntry: WorkoutSupersetLayout.Entry?
    let joinsPrevious: Bool
    let joinsNext: Bool
    let animation: Namespace.ID
    let onRemove: () -> Void

    private static let radius: CGFloat = 16

    private var sets: [WorkoutSetModel] {
        exercise.sets.enumerated().map { index, set in set.setModel(orderIndex: index, id: set.id) }
    }

    private var shape: UnevenRoundedRectangle {
        UnevenRoundedRectangle(
            topLeadingRadius: joinsPrevious ? 0 : Self.radius,
            bottomLeadingRadius: joinsNext ? 0 : Self.radius,
            bottomTrailingRadius: joinsNext ? 0 : Self.radius,
            topTrailingRadius: joinsPrevious ? 0 : Self.radius,
            style: .continuous
        )
    }

    var body: some View {
        VStack(spacing: 0) {
            header

            if !sets.isEmpty {
                Divider()
                    .padding(.horizontal, 16)
                setsRow
            }
        }
        .background(Color(UIColor.secondarySystemGroupedBackground), in: shape)
        .clipShape(shape)
    }

    // MARK: - Header

    private var header: some View {
        HStack(spacing: 12) {
            leadingTile

            VStack(alignment: .leading, spacing: 3) {
                Text(exercise.exercise.name)
                    .font(.system(size: 16, weight: .semibold))
                    .foregroundStyle(Color.primary)
                    .lineLimit(1)
                Text(sets.count == 1 ? "1 set" : "\(sets.count) sets")
                    .font(.system(size: 13))
                    .foregroundStyle(Color.secondary)
            }

            Spacer(minLength: 0)

            Button(action: onRemove) {
                Image(systemName: "xmark")
                    .font(.system(size: 11, weight: .bold))
                    .foregroundStyle(Color.secondary)
                    .frame(width: 28, height: 28)
                    .background(Color(UIColor.tertiarySystemFill), in: Circle())
                    .frame(width: 44, height: 44)
                    .contentShape(Rectangle())
            }
            .buttonStyle(.plain)
            .accessibilityLabel("Remove \(exercise.exercise.name)")
        }
        .padding(.leading, 16)
        .padding(.trailing, 8)
        .padding(.vertical, 8)
    }

    @ViewBuilder
    private var leadingTile: some View {
        if let supersetEntry {
            WorkoutSupersetBadge(entry: supersetEntry)
                .frame(width: 36, height: 36)
        } else {
            // The solid tile the library rows use.
            RoundedRectangle(cornerRadius: 10, style: .continuous)
                .fill(Color.darkColor)
                .frame(width: 36, height: 36)
                .overlay(
                    Image(systemName: "dumbbell.fill")
                        .font(.system(size: 14, weight: .semibold))
                        .foregroundStyle(.white)
                )
        }
    }

    // MARK: - Sets Row

    private var setsRow: some View {
        ScrollView(.horizontal, showsIndicators: false) {
            HStack(spacing: 8) {
                ForEach(Array(sets.enumerated()), id: \.element.id) { index, set in
                    // Nothing to open: the set is still being built, and the overlay reads a
                    // template the builder has not made yet.
                    MyDayTemplateSetPill(
                        index: index,
                        set: set,
                        matchedId: SessionSetDetail.matchedId(exerciseId: exercise.exercise.id, setId: set.id),
                        animation: animation
                    )
                }
            }
            .padding(.horizontal, 16)
            .padding(.vertical, 10)
        }
    }
}
