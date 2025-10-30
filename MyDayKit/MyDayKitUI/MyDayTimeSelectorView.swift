//
//  MyDayTimeSelectorView.swift
//  MyDayKit
//
//  Created by Findlay Wood on 30/10/2025.
//

import SwiftUI

struct MyDayTimeSelectorView: View {
    
    @State private var value: Int = 0
    
    private var isValidSelection: Bool {
        value > 0
    }
    
    let columns = [
        GridItem(.flexible()), GridItem(.flexible()), GridItem(.flexible())
    ]
    
    // Time adjustment steps — these make sense for both seconds and minutes
    let secondSteps: [Int] = [1, 5, 10, 30, 60, 300] // 1s to 5min
    
    let newExercise: MyDayNewExerciseManager
    
    var continueAction: (() -> ())?
    
    var body: some View {
        VStack(spacing: 24) {
            
            // Unit selection grid
            Text("Select Time")
                .font(.headline)
            
            // Numeric input controls
            VStack(spacing: 16) {
                Text(displayTime(for: value))
                    .font(.system(size: 30, weight: .bold))
                    .monospacedDigit()
                
                let steps = secondSteps
                
                HStack(spacing: 24) {
                    // Negative side
                    LazyVGrid(columns: columns, spacing: 8) {
                        ForEach(steps, id: \.self) { step in
                            Button(action: {
                                value = max(0, value - step)
                            }) {
                                Text("-\(formattedStep(step))")
                                    .frame(maxWidth: .infinity)
                                    .padding(.vertical, 8)
                                    .background(Color.red.opacity(0.2))
                                    .clipShape(RoundedRectangle(cornerRadius: 8))
                            }
                        }
                    }
                    .frame(maxWidth: .infinity)
                    
                    // Positive side
                    LazyVGrid(columns: columns, spacing: 8) {
                        ForEach(steps, id: \.self) { step in
                            Button(action: {
                                value = min(999_999, value + step)
                            }) {
                                Text("+\(formattedStep(step))")
                                    .frame(maxWidth: .infinity)
                                    .padding(.vertical, 8)
                                    .background(Color.green.opacity(0.2))
                                    .clipShape(RoundedRectangle(cornerRadius: 8))
                            }
                        }
                    }
                    .frame(maxWidth: .infinity)
                }
            }
            
            Spacer()
            
            // Continue button
            Button {
                addAction()
            } label: {
                Text("Add")
                    .frame(maxWidth: .infinity)
                    .padding()
                    .background(isValidSelection ? Color.blue : Color.gray.opacity(0.4))
                    .foregroundColor(.white)
                    .clipShape(RoundedRectangle(cornerRadius: 12))
            }
            .disabled(!isValidSelection)
            
        }
        .padding()
    }
    
    // MARK: - Helpers
    
    func formattedStep(_ step: Int) -> String {
        if step >= 60 {
            return "\(step / 60)m"
        } else {
            return "\(step)s"
        }
    }
    
    func displayTime(for totalSeconds: Int) -> String {
        let minutes = totalSeconds / 60
        let seconds = totalSeconds % 60
        
        return String(format: "%d:%02d", minutes, seconds)
    }
    
    func addAction() {
        newExercise.setTime(value)
        continueAction?()
    }
}


#Preview {
    MyDayTimeSelectorView(newExercise: .init(exercise: .pressUps))
}
