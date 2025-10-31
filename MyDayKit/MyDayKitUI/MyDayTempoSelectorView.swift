//
//  MyDayTempoSelectorView.swift
//  MyDayKit
//
//  Created by Findlay Wood on 31/10/2025.
//

import SwiftUI

struct MyDayTempoSelectorView: View {
    
    @State private var tempo: Tempo = Tempo(eccentric: 0, eccentricHold: 0, concentric: 0, concentricHold: 0)
    
    private var isValidSelection: Bool {
        tempo.eccentric > 0 || tempo.eccentricHold > 0 || tempo.concentric > 0 || tempo.concentricHold > 0
    }
    
    let newExercise: MyDayNewExerciseManager
    var continueAction: (() -> ())?
    
    var body: some View {
        VStack(spacing: 24) {
            
            Text("Select Tempo (Down-Hold-Up-Hold)")
                .font(.headline)
            
            HStack(spacing: 16) {
                // Eccentric
                tempoColumn(label: "Down", value: $tempo.eccentric)
                
                // Eccentric Hold
                tempoColumn(label: "Hold1", value: $tempo.eccentricHold)
                
                // Concentric
                tempoColumn(label: "Up", value: $tempo.concentric)
                
                // Concentric Hold
                tempoColumn(label: "Hold2", value: $tempo.concentricHold)
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
    
    @ViewBuilder
    private func tempoColumn(label: String, value: Binding<Int>) -> some View {
        VStack(spacing: 8) {
            Text(label)
                .font(.subheadline)
            
            // + Button
            Button(action: { value.wrappedValue += 1 }) {
                Text("+")
                    .font(.title2)
                    .frame(width: 40, height: 40)
                    .background(Color.green.opacity(0.2))
                    .clipShape(Circle())
            }
            
            // Current value
            Text("\(value.wrappedValue)")
                .font(.title2)
                .frame(width: 40)
                .monospacedDigit()
            
            // - Button
            Button(action: { value.wrappedValue = max(0, value.wrappedValue - 1) }) {
                Text("-")
                    .font(.title2)
                    .frame(width: 40, height: 40)
                    .background(Color.red.opacity(0.2))
                    .clipShape(Circle())
            }
        }
    }
    
    private func addAction() {
        newExercise.setTempo(tempo)
        continueAction?()
    }
}

#Preview {
    MyDayTempoSelectorView(newExercise: .init(exercise: .squat))
}

struct Tempo {
    var eccentric: Int
    var eccentricHold: Int
    var concentric: Int
    var concentricHold: Int
    
}
