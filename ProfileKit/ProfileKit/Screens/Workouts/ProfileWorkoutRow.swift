//
//  ProfileWorkoutRow.swift
//  ProfileKit
//
//  Created by Findlay Wood on 12/11/2026.
//

import SwiftUI

/// A workout on a profile: the section, its see-all list and All workouts.
///
/// **ProfileKit's copy of DiscoverKit's `DiscoverWorkoutRow`, kept in step with it**: title over
/// two lines, the date, exercise / rating / comment pills, up to three tags, no icon tile, always a
/// card of its own. It drops the row's "by Name": every workout on a profile is that person's, so
/// the byline would repeat the header.
///
/// **A private workout carries a lock in its top-right corner.** Only All workouts lists private
/// ones; it is the one thing that tells someone which of their workouts others can see.
struct ProfileWorkoutRow: View {
    let workout: ProfileWorkout

    var body: some View {
        HStack(spacing: 12) {
            VStack(alignment: .leading, spacing: 8) {
                VStack(alignment: .leading, spacing: 3) {
                    Text(workout.title.isEmpty ? "Untitled workout" : workout.title)
                        .font(.system(size: 17, weight: .semibold))
                        .foregroundStyle(.primary)
                        .lineLimit(2)
                        .multilineTextAlignment(.leading)
                        // Clear of the lock, which sits over the trailing corner.
                        .padding(.trailing, workout.showsLock ? 20 : 0)
                    if let date = workout.createdAt?.formatted(.dateTime.day().month(.abbreviated)) {
                        Text(date)
                            .font(.system(size: 13))
                            .foregroundStyle(.secondary)
                            .lineLimit(1)
                    }
                }
                HStack(spacing: 6) {
                    ProfileMetaPill(systemImage: "list.bullet", text: exerciseCount)
                    if let average = workout.averageRating, let count = workout.ratingCount {
                        ProfileMetaPill(systemImage: "star.fill", text: String(format: "%.1f", average) + " (\(count))")
                    }
                    if let comments = workout.commentCount, comments > 0 {
                        ProfileMetaPill(systemImage: "bubble.left", text: "\(comments)")
                    }
                }
                if let tags = workout.tags, !tags.isEmpty {
                    Text(tags.prefix(3).map { "#\($0)" }.joined(separator: "  "))
                        .font(.system(size: 13, weight: .medium))
                        .foregroundStyle(Color.darkColor)
                        .lineLimit(1)
                }
            }
            Spacer(minLength: 0)
            Image(systemName: "chevron.right")
                .font(.system(size: 13, weight: .semibold))
                .foregroundStyle(.tertiary)
        }
        .padding(16)
        .background(
            RoundedRectangle(cornerRadius: 16, style: .continuous)
                .fill(Color(.secondarySystemBackground))
        )
        .overlay(alignment: .topTrailing) {
            if workout.showsLock {
                Image(systemName: "lock.fill")
                    .font(.system(size: 12, weight: .semibold))
                    .foregroundStyle(Color.secondary)
                    .padding(12)
                    .accessibilityLabel("Private")
            }
        }
        .contentShape(Rectangle())
    }

    private var exerciseCount: String {
        workout.exerciseCount == 1 ? "1 exercise" : "\(workout.exerciseCount) exercises"
    }
}
