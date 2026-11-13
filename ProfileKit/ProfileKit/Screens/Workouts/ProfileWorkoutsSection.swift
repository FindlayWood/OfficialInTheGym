//
//  ProfileWorkoutsSection.swift
//  ProfileKit
//
//  Created by Findlay Wood on 12/11/2026.
//

import SwiftUI

/// The Workouts section on a profile: that person's newest public workouts, the same on everyone's
/// screen, yours included (`PROFILE_WORKOUTS_PLAN.md`).
///
/// It shows `previewCount` rows, and a See all when there are more, which is why the view models
/// ask for one more than that. **Your own profile adds All workouts** in the header, your whole
/// library private ones included, when the router can open it (`onOpenAllWorkouts` non-`nil`).
///
/// An empty section is drawn on your own profile, so you know where workouts will appear and
/// All workouts still has somewhere to live, and not drawn on someone else's, as with clips.
struct ProfileWorkoutsSection: View {

    static let previewCount = 3

    let workouts: [ProfileWorkout]
    let isOwnProfile: Bool
    let onOpenWorkout: (ProfileWorkout) -> Void
    let onSeeAll: (() -> Void)?
    let onOpenAllWorkouts: (() -> Void)?

    var body: some View {
        if isOwnProfile || !workouts.isEmpty {
            VStack(alignment: .leading, spacing: 8) {
                header

                if workouts.isEmpty {
                    Text("Workouts you make public show here.")
                        .font(.system(size: 14))
                        .foregroundStyle(Color.secondary)
                        .frame(maxWidth: .infinity, alignment: .leading)
                        .padding(16)
                        .background(
                            RoundedRectangle(cornerRadius: 16, style: .continuous)
                                .fill(Color(.secondarySystemBackground))
                        )
                } else {
                    VStack(spacing: 10) {
                        ForEach(workouts.prefix(Self.previewCount)) { workout in
                            Button {
                                onOpenWorkout(workout)
                            } label: {
                                ProfileWorkoutRow(workout: workout)
                            }
                            .buttonStyle(.plain)
                        }
                    }
                    if workouts.count > Self.previewCount, let onSeeAll {
                        Button(action: onSeeAll) {
                            Text("See all")
                                .font(.system(size: 14, weight: .semibold))
                                .foregroundStyle(Color.darkColor)
                                .frame(maxWidth: .infinity)
                                .frame(height: 44)
                        }
                        .buttonStyle(.plain)
                    }
                }
            }
        }
    }

    private var header: some View {
        HStack {
            Text("Workouts")
                .font(.system(size: 13, weight: .semibold))
                .foregroundStyle(Color.secondary)
                .textCase(.uppercase)
                .tracking(0.8)
            Spacer()
            if isOwnProfile, let onOpenAllWorkouts {
                Button(action: onOpenAllWorkouts) {
                    HStack(spacing: 4) {
                        Text("All workouts")
                        Image(systemName: "chevron.right")
                            .font(.system(size: 11, weight: .semibold))
                    }
                    .font(.system(size: 13, weight: .semibold))
                    .foregroundStyle(Color.darkColor)
                    .frame(minHeight: 32)
                }
                .buttonStyle(.plain)
            }
        }
        .padding(.horizontal, 4)
    }
}
