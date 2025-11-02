//
//  MyDayNoteSelectorView.swift
//  MyDayKit
//
//  Created by Findlay Wood on 31/10/2025.
//

import SwiftUI

struct MyDayNoteSelectorView: View {
    
    @State private var noteText: String
    
    let newExercise: MyDayNewExerciseManager
    var continueAction: (() -> ())?
    
    init(newExercise: MyDayNewExerciseManager, continueAction: (() -> ())? = nil) {
        self.newExercise = newExercise
        self.continueAction = continueAction
        self._noteText = State(initialValue: newExercise.note ?? "")
    }
    
    var body: some View {
        VStack(spacing: 24) {
            
            Text("Add a Note")
                .font(.headline)
            
            // Text editor with border
            ZStack(alignment: .topLeading) {
                if noteText.isEmpty {
                    Text("Enter your note here...")
                        .foregroundColor(Color.gray.opacity(0.6))
                        .padding(8)
                }
                
                TextEditor(text: $noteText)
                    .padding(4)
                    .background(Color.gray.opacity(0.1))
                    .cornerRadius(8)
                    .frame(minHeight: 100)
            }
            
            Spacer()
            
            // Save/Add button
            Button {
                addAction()
            } label: {
                Text("Add")
                    .frame(maxWidth: .infinity)
                    .padding()
                    .background(!noteText.isEmpty ? Color.blue : Color.gray.opacity(0.4))
                    .foregroundColor(.white)
                    .clipShape(RoundedRectangle(cornerRadius: 12))
            }
            .disabled(noteText.isEmpty)
            
        }
        .padding()
    }
    
    private func addAction() {
        newExercise.setNote(noteText)
        continueAction?()
    }
}


#Preview {
    MyDayNoteSelectorView(newExercise: .init(exercise: .pressUps))
}
