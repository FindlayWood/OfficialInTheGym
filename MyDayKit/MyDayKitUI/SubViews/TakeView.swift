//
//  TakeView.swift
//  MyDayKit
//
//  Created by Findlay Wood on 02/11/2025.
//

import SwiftUI

struct TakeView: View {
    
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
                            VStack {
                                Text("\(completion.reps)")
                                if let weight = completion.weight, let unit = completion.weightUnit {
                                    Text("\(weight) \(unit.rawValue)")
                                }
                            }
                            .padding()
                            .background {
                                Color.white
                                    .clipShape(RoundedRectangle(cornerRadius: 8))
                                    .shadow(radius: 2)
                            }
                            .overlay {
                                RoundedRectangle(cornerRadius: 8)
                                    .stroke(Color.black, lineWidth: 1)
                            }
                            
                            
                        }
                        
                        if model.completions.count > 0 && !disabled {
                            Button {
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
                            } label: {
                                VStack {
                                    Image(systemName: "arrow.counterclockwise")
                                    Text("Repeat")
                                }
                                .padding()
                                .overlay {
                                    RoundedRectangle(cornerRadius: 8)
                                        .stroke(Color.black, lineWidth: 1)
                                }
                            }
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
    TakeView(
        model: .init(
            id: "",
            date: .now,
            exercise: .pressUps,
            completions: []
        ),
        disabled: false
    )
}
