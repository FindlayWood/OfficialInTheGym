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
                        if index > 0 {
                            Divider().padding(.leading, 56)
                        }
                        row(exercise, number: index + 1)
                    }
                }
            }
        }
    }

    private func row(_ exercise: DiscoverWorkoutExercise, number: Int) -> some View {
        HStack(alignment: .top, spacing: 12) {
            Text("\(number)")
                .font(.system(size: 14, weight: .bold))
                .foregroundStyle(.white)
                .frame(width: 28, height: 28)
                .background(Color.darkColor, in: Circle())
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
        .padding(.horizontal, 16)
        .padding(.vertical, 12)
    }
}
