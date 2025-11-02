//
//  TakeView.swift
//  MyDayKit
//
//  Created by Findlay Wood on 02/11/2025.
//

import SwiftUI

struct ExerciseCompletionView: View {
    
    @ObservedObject var model: MyDayExerciseModel
    
    let disabled: Bool
    
    var addAction: (() -> ())?
    var addClipButtonAction: (() -> ())?
    var repeatSet: ((ExerciseCompletions) -> ())?
    
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
                        Image(systemName: "plus.circle.fill")
                            .resizable()
                            .frame(width: 25, height: 25)
                    }
                    .buttonStyle(.borderless)
                }
            }
            HStack {
                ScrollView(.horizontal, showsIndicators: false) {
                    HStack {
                        ForEach(model.completions) { completion in
                            CompletedSetView(model: completion)
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
                                        note: last.note
                                    )
                                    repeatSet?(newCompleteion)
                                })
                        }
                    }
                    .padding()
                }
            }
            
            if !disabled {
                VStack {
                    Button {
                        addClipButtonAction?()
                    } label: {
                        Text("Add Clip")
                        Image(systemName: "plus.circle.fill")
                    }
                    .buttonStyle(.plain)
                }
            }
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
    ExerciseCompletionView(
        model: .init(
            id: "",
            date: .now,
            exercise: .pressUps,
            completions: []
        ),
        disabled: false
    )
}
