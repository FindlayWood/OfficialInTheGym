//
//  TakeView.swift
//  MyDayKit
//
//  Created by Findlay Wood on 02/11/2025.
//

import SwiftUI

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
    
    var body: some View {
        VStack(spacing: 0) {
            
            // ── Header ─────────────────────────────────────────────────
            HStack(alignment: .center) {
                Text(model.exercise.name)
                    .font(.system(size: 18, weight: .bold))
                    .foregroundStyle(Color.primary)
                    .lineLimit(1)
                    .minimumScaleFactor(0.8)
                
                Spacer()
                
                if !disabled {
                    Button {
                        addAction?()
                    } label: {
                        HStack(spacing: 4) {
                            Image(systemName: "plus")
                                .font(.system(size: 12, weight: .bold))
                            Text("Add Set")
                                .font(.system(size: 13, weight: .semibold))
                        }
                        .foregroundStyle(Color.blue)
                        .padding(.horizontal, 12)
                        .padding(.vertical, 6)
                        .background(Color.blue.opacity(0.1))
                        .clipShape(Capsule())
                    }
                    .buttonStyle(.borderless)
                }
            }
            .padding(.horizontal, 16)
            .padding(.top, 16)
            .padding(.bottom, 12)
            
            // ── Sets scroll ────────────────────────────────────────────
            if model.completions.isEmpty {
                HStack {
                    Text("No sets recorded yet")
                        .font(.system(size: 13, weight: .regular))
                        .foregroundStyle(Color.secondary)
                    Spacer()
                }
                .padding(.horizontal, 16)
                .padding(.bottom, 12)
            } else {
                ScrollView(.horizontal, showsIndicators: false) {
                    HStack(spacing: 8) {
                        ForEach(model.completions) { completion in
                            if let selected, selected.id == completion.id {
                                PlaceholderSetView(model: completion)
                            } else {
                                CompletedSetView(
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
                    .padding(.vertical, 4)
                }
                .padding(.bottom, 8)
            }
            
            // ── Clips ──────────────────────────────────────────────────
            if !model.clips.isEmpty || !disabled {
                Divider()
                    .padding(.horizontal, 16)
                    .padding(.bottom, 12)
                
                ExerciseClipsSubView(
                    clips: model.clips,
                    canAdd: !disabled,
                    addAction: { addClipButtonAction?() },
                    selectedClip: clipSelected
                )
                .padding(.horizontal, 16)
                .padding(.bottom, 16)
            }
        }
        .background(Color.white)
        .clipShape(RoundedRectangle(cornerRadius: 16))
        .shadow(color: Color.black.opacity(0.06), radius: 8, x: 0, y: 2)
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
