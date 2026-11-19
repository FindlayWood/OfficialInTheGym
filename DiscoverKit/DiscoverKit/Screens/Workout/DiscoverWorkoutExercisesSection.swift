//
//  DiscoverWorkoutExercisesSection.swift
//  DiscoverKit
//
//  Created by Findlay Wood on 02/10/2026.
//

import SwiftUI

/// What is in a workout: each exercise with its sets summarised on one line,
/// and the author's note where there is one.
struct DiscoverWorkoutExercisesSection: View {

    let state: DiscoverSectionState<DiscoverWorkoutDetail>
    let onRetry: () -> Void

    var body: some View {
        SectionContainer(title: "Exercises") {
            switch state {
            case .loading:
                VStack(spacing: 0) {
                    DiscoverRowSkeleton()
                    DiscoverRowSkeleton()
                    DiscoverRowSkeleton()
                }
            case .failed:
                DiscoverSectionMessage(message: "Couldn't load this workout", retry: onRetry)
            case .loaded(let detail) where detail.exercises.isEmpty:
                DiscoverSectionMessage(message: "This workout has no exercises")
            case .loaded(let detail):
                VStack(spacing: 0) {
                    ForEach(Array(detail.exercises.enumerated()), id: \.element.id) { index, exercise in
                        // Rows in one superset are joined by a line between their badges, not
                        // separated by a divider.
                        if index > 0 && !detail.exercises[index - 1].continuesSuperset {
                            Divider().padding(.leading, 56)
                        }
                        row(exercise, label: exercise.supersetLabel ?? "\(index + 1)")
                    }
                }
            }
        }
    }

    private func row(_ exercise: DiscoverWorkoutExercise, label: String) -> some View {
        HStack(alignment: .top, spacing: 12) {
            Text(label)
                .font(.system(size: label.count > 1 ? 13 : 14, weight: .bold))
                .foregroundStyle(.white)
                .lineLimit(1)
                .minimumScaleFactor(0.7)
                .frame(width: 28, height: 28)
                .background(Color.darkColor, in: Circle())
                .frame(maxHeight: .infinity, alignment: .top)
                .background(alignment: .top) {
                    // Runs from this badge down to the next row's, through this row's bottom
                    // padding and the next row's top padding (12 each).
                    if exercise.continuesSuperset {
                        Capsule()
                            .fill(Color.darkColor)
                            .frame(width: 3)
                            .padding(.top, 28)
                            .padding(.bottom, -24)
                    }
                }
            VStack(alignment: .leading, spacing: 3) {
                Text(exercise.name)
                    .font(.system(size: 15, weight: .semibold))
                Text(exercise.summary)
                    .font(.system(size: 13))
                    .foregroundStyle(.secondary)
                if let notes = exercise.notes, !notes.trimmingCharacters(in: .whitespaces).isEmpty {
                    Label(notes, systemImage: "text.quote")
                        .font(.system(size: 13))
                        .foregroundStyle(.secondary)
                        .labelStyle(.titleAndIcon)
                }
            }
            Spacer(minLength: 0)
        }
        // So the badge column is as tall as the text beside it, which is what the line runs down.
        .fixedSize(horizontal: false, vertical: true)
        .padding(.horizontal, 16)
        .padding(.vertical, 12)
    }
}
