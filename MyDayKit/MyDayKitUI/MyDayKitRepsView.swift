//
//  MyDayKitRepsView.swift
//  MyDayKit
//
//  Created by Findlay Wood on 12/08/2025.
//

import SwiftUI

struct MyDayKitRepsView: View {
    
    @ObservedObject var dayManager: MyDayManager
    
    let exercise: MyDayNewExerciseManager
    @State var reps: Int = 0
    
    // Range of possible reps
    let minReps = 0
    let maxReps = 50
    
    var add: (() -> ())?
    
    var body: some View {
        VStack(spacing: 20) {
            Text("How many reps did you complete?")
                .font(.headline)
            
            Text(exercise.exercise.name)
                .font(.title2)
                .bold()
            
            Stepper(value: $reps, in: minReps...maxReps) {
                Text("\(reps) reps")
                    .font(.title3)
                    .monospacedDigit()
            }
            .padding()
            
            Slider(value: Binding(
                get: { Double(reps) },
                set: { reps = Int($0) }
            ), in: Double(minReps)...Double(maxReps), step: 1)
            .accentColor(.blue)
            .padding(.horizontal)
            
            Button {
                addAction()
            } label: {
                Text("Add")
                    .font(.headline)
                    .foregroundStyle(Color.white)
                    .padding()
                    .frame(maxWidth: .infinity)
                    .background {
                        Color.blue
                            .clipShape(RoundedRectangle(cornerRadius: 10))
                    }
            }
        }
        .padding()
    }
    
    func addAction() {
        exercise.setReps(reps)
        add?()
    }
}

#Preview {
    MyDayKitRepsView(dayManager: MyDayManager(), exercise: MyDayNewExerciseManager(exercise: .pressUps))
}
