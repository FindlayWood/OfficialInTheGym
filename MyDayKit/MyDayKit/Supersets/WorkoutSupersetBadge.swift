//
//  WorkoutSupersetBadge.swift
//  MyDayKit
//
//  Created by Findlay Wood on 18/11/2026.
//

import SwiftUI

/// An exercise's place in the workout, "1a" or "2", in a solid `darkColor` tile — the same mark
/// DISCOVER's workout page has always numbered its exercises with, so the two read alike.
///
/// Drawn only on a workout that has a superset (`WorkoutSupersetLayout.hasSupersets`); a workout
/// without one looks exactly as it did before supersets.
struct WorkoutSupersetBadge: View {

    let entry: WorkoutSupersetLayout.Entry

    /// The badge's smallest width and its height. `supersetConnector` centres its line on it.
    static let size: CGFloat = 28

    var body: some View {
        Text(entry.label)
            .font(.system(size: 13, weight: .bold))
            .foregroundStyle(.white)
            .lineLimit(1)
            .minimumScaleFactor(0.7)
            .padding(.horizontal, 4)
            .frame(minWidth: Self.size, minHeight: Self.size)
            .background(Color.darkColor, in: Capsule())
    }
}
