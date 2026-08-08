//
//  TakeView.swift
//  MyDayKit
//
//  Created by Findlay Wood on 02/11/2025.
//

import SwiftUI

/// The MyDay home screen's card for one exercise's logged sets.
///
/// Laid out to mirror `MyDayWorkoutSessionExerciseCard` — the same header /
/// divider / sets row / divider / actions row structure, typography and
/// chrome — so an exercise logged on its own and an exercise logged inside a
/// workout read as the same kind of thing. **Keep the two in step.**
///
/// Only the presentation changed: every callback, the matched-geometry set
/// hero, the repeat-set affordance and the clips list all behave exactly as
/// they did. Adding a set and adding a clip moved out of the header and the
/// clips block into the shared actions row, which is where the session card
/// puts its actions.
struct ExerciseCompletionView: View {

    @ObservedObject var model: MyDayExerciseModel

    var selected: ExerciseCompletions?

    let disabled: Bool
    let animation: Namespace.ID

    var addAction: (() -> ())?
    var addClipButtonAction: (() -> ())?
    var repeatSet: ((ExerciseCompletions) -> ())?
    var onTap: ((ExerciseCompletions) -> ())?
    var clipSelected: ((MyDayClipModel, UIImage, CGRect) -> ())?

    /// The reps of every logged set, as the session card summarises its own.
    private var completedRepsText: String {
        model.completions.map { "\($0.reps)" }.joined(separator: ", ")
    }

    var body: some View {
        VStack(spacing: 0) {
            header

            Divider()
                .padding(.horizontal, 16)
            setsRow

            if !model.clips.isEmpty {
                Divider()
                    .padding(.horizontal, 16)
                clipsRow
            }

            if !disabled {
                Divider()
                    .padding(.horizontal, 16)
                actionsRow
            }
        }
        .background(Color.white)
        .clipShape(RoundedRectangle(cornerRadius: 16, style: .continuous))
        .shadow(color: Color.black.opacity(0.06), radius: 8, x: 0, y: 2)
    }

    // MARK: - Header

    private var header: some View {
        HStack(spacing: 12) {
            VStack(alignment: .leading, spacing: 3) {
                Text(model.exercise.name)
                    .font(.system(size: 16, weight: .semibold))
                    .foregroundStyle(Color.primary)
                    .lineLimit(1)
                    .minimumScaleFactor(0.8)

                if !completedRepsText.isEmpty {
                    Text(completedRepsText)
                        .font(.system(size: 13))
                        .foregroundStyle(Color.secondary)
                        .animation(.easeInOut(duration: 0.2), value: completedRepsText)
                }
            }

            Spacer()
        }
        .padding(16)
    }

    // MARK: - Sets Row

    @ViewBuilder
    private var setsRow: some View {
        if model.completions.isEmpty {
            HStack {
                Text("No sets recorded yet")
                    .font(.system(size: 13, weight: .regular))
                    .foregroundStyle(Color.secondary)
                Spacer()
            }
            .padding(.horizontal, 16)
            .padding(.vertical, 14)
        } else {
            ScrollView(.horizontal, showsIndicators: false) {
                HStack(spacing: 8) {
                    ForEach(Array(model.completions.enumerated()), id: \.element.id) { index, completion in
                        if let selected, selected.id == completion.id {
                            PlaceholderSetView(index: index, model: completion)
                        } else {
                            CompletedSetView(
                                index: index,
                                model: completion,
                                animation: animation
                            )
                            .onTapGesture {
                                onTap?(completion)
                            }
                        }
                    }

                    if !model.completions.isEmpty && !disabled {
                        RepeatSetView(
                            lastReps: model.completions.last?.reps,
                            lastWeight: model.completions.last?.weight,
                            lastWeightUnit: model.completions.last?.weightUnit,
                            action: {
                                guard let last = model.completions.last else { return }
                                let newCompletion = ExerciseCompletions(
                                    id: UUID().uuidString,
                                    exercise: model.exercise,
                                    reps: last.reps,
                                    weight: last.weight,
                                    weightUnit: last.weightUnit,
                                    dateCompleted: .now,
                                    distance: last.distance,
                                    distanceUnits: last.distanceUnits,
                                    time: last.time,
                                    tempo: last.tempo,
                                    note: last.note,
                                    eachSide: last.eachSide
                                )
                                repeatSet?(newCompletion)
                            }
                        )
                    }
                }
                .padding(.horizontal, 16)
                .padding(.vertical, 10)
            }
        }
    }

    // MARK: - Clips Row

    /// Thumbnails only. `canAdd` is false because adding a clip is now the
    /// actions row's job — leaving it true would draw a second add button
    /// inside the strip, and its empty state would duplicate the row entirely.
    private var clipsRow: some View {
        ExerciseClipsSubView(
            clips: model.clips,
            canAdd: false,
            selectedClip: clipSelected
        )
        .padding(.horizontal, 12)
        .padding(.vertical, 8)
    }

    // MARK: - Actions Row

    private var actionsRow: some View {
        HStack(spacing: 0) {
            actionButton(
                title: "Add Set",
                icon: "plus",
                tint: Color.darkColor,
                action: { addAction?() }
            )

            Divider()
                .frame(height: 18)

            actionButton(
                title: "Clip",
                icon: "camera.fill",
                tint: Color.secondary,
                action: { addClipButtonAction?() }
            )
        }
        .padding(.horizontal, 16)
    }

    private func actionButton(
        title: String,
        icon: String,
        tint: Color,
        action: @escaping () -> Void
    ) -> some View {
        Button(action: action) {
            HStack(spacing: 6) {
                Image(systemName: icon)
                    .font(.system(size: 14, weight: .medium))
                Text(title)
                    .font(.system(size: 14, weight: .semibold))
            }
            .foregroundStyle(tint)
            .frame(maxWidth: .infinity)
            .padding(.vertical, 12)
        }
        .buttonStyle(.plain)
    }
}

#Preview {
    @Previewable @Namespace var animation
    ExerciseCompletionView(
        model: .init(
            id: "",
            date: .now,
            exercise: .pressUps,
            completions: [.init(
                id: UUID().uuidString,
                exercise: .pressUps,
                reps: 25,
                weight: nil,
                weightUnit: .bw,
                dateCompleted: .now,
                distance: nil,
                distanceUnits: nil,
                time: nil,
                tempo: nil,
                note: nil,
                eachSide: false
            )],
            clips: [.init(
                id: UUID().uuidString,
                clipID: UUID().uuidString,
                exerciseID: UUID().uuidString,
                dateUploaded: .now,
                thumbnailURL: URL(string: "https://firebasestorage.googleapis.com:443/v0/b/inthegym-2353b.appspot.com/o/TestClipThumbnails%2FfZKSEr4e6yWdYqt0P6BXbnyg1pf2%2F810FB504-DADF-4E76-9B6E-89A1FE2DC827?alt=media&token=59c6f5f7-a153-4c5b-ab16-aa8c7bf8f56a")
            )]
        ),
        selected: nil,
        disabled: false,
        animation: animation
    )
}
