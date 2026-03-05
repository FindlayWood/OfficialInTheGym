//
//  MyDayKitRepsView.swift
//  MyDayKit
//
//  Created by Findlay Wood on 12/08/2025.
//

import SwiftUI

struct MyDayKitRepsView: View {
    
    @ObservedObject var dayManager: MyDayManager
    
    @ObservedObject var exercise: MyDayNewExerciseManager
    @State var reps: Int = 0
    @State private var stringInput: String = ""
    
    var add: (() -> ())?
    
    var body: some View {
        VStack {
            Text("How many reps of \(exercise.exercise.name) did you complete?")
                .font(.headline)
                .multilineTextAlignment(.center)
                .padding()
            
            Spacer()
            
            Text("\(stringInput.isEmpty ? "-" : "\(reps)")")
                .font(.system(size: 60, weight: .bold))
                .foregroundStyle(Color.black)
                .frame(maxWidth: .infinity, alignment: .center)
                .minimumScaleFactor(0.5)
                .lineLimit(1)
                .background {
                    RoundedRectangle(cornerRadius: 10)
                        .fill(Color.black.opacity(0.1))
                        .overlay {
                            RoundedRectangle(cornerRadius: 10)
                                .stroke(Color.black, lineWidth: 1)
                        }
                }
                .padding()
            
            Spacer()
            
            VStack(alignment: .leading) {
                Toggle("Each Side", isOn: $exercise.eachSide)
                    .tint(Color.blue)
                    .font(.system(size: 16, weight: .medium))
                Text("Mark this if the exercise was completed each side.")
                    .font(.system(size: 10, weight: .medium))
                    .foregroundStyle(Color.black.opacity(0.5))
                    .frame(maxWidth: .infinity, alignment: .leading)
            }
            .padding(.horizontal)
            
            CustomNumberPad(
                backspaceDisabled: stringInput.isEmpty,
                zeroDisabled: stringInput.isEmpty,
                selection: { number in
                    stringInput.append("\(number)")
                    reps = Int(stringInput) ?? 1
                },
                backspace:  {
                    stringInput.removeLast()
                    reps = Int(stringInput) ?? 1
                }
            )
            
            
            Button {
                addAction()
            } label: {
                Text("Add")
                    .font(.headline)
                    .foregroundStyle(Color.white.opacity(stringInput.isEmpty ? 0.3 : 1))
                    .padding()
                    .frame(maxWidth: .infinity)
                    .background {
                        Color
                            .blue.opacity(stringInput.isEmpty ? 0.3 : 1)
                            .clipShape(RoundedRectangle(cornerRadius: 10))
                    }
            }
            .padding()
            .disabled(stringInput.isEmpty)
        }
        .navigationTitle("Reps")
        .onAppear {
            guard let currentReps = exercise.reps else { return }
            stringInput = "\(currentReps)"
            reps = currentReps
        }
    }
    
    func addAction() {
        exercise.setReps(reps)
        add?()
    }
}

#Preview {
    MyDayKitRepsView(
        dayManager: MyDayManager(
            saver: PreviewSaver(),
            clipSaver: PreviewMyDaySaver(),
            deleteSaver: PreviewMyDaySaver(),
            loader: PreviewLoader(),
            deleter: PreviewMyDayDeleter()
        ),
        exercise: MyDayNewExerciseManager(exercise: .pressUps)
    )
}
