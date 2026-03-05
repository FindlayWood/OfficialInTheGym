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
        VStack {
            HStack {
                Text(model.exercise.name)
                    .font(.title)
                    .fontWeight(.bold)
                    .foregroundStyle(Color.primary)
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
            HStack {
                ScrollView(.horizontal, showsIndicators: false) {
                    HStack {
                        ForEach(model.completions) { completion in
                            if let selected, selected.id == completion.id {
                                PlaceholderSetView(
                                    model: completion
                                )
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
                        
                        if model.completions.count > 0 && !disabled {
                            RepeatSetView(
                                action: {
                                    guard let last = model.completions.last else { return }
                                    let newCompleteion = ExerciseCompletions(
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
                                    repeatSet?(newCompleteion)
                                })
                        }
                    }
                    .padding()
                }
            }
            
            ExerciseClipsSubView(
                clips: model.clips,
                canAdd: !disabled,
                addAction: {
                    addClipButtonAction?()
                },
                selectedClip: clipSelected
            )
        }
        .padding()
        .background {
            Color
                .white
                .shadow(radius: 4)
        }
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
