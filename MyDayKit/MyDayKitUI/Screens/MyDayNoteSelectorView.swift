//
//  MyDayNoteSelectorView.swift
//  MyDayKit
//
//  Created by Findlay Wood on 31/10/2025.
//

import SwiftUI

struct MyDayNoteSelectorView: View {
    
    @State private var noteText: String
    @FocusState private var isFocused: Bool
    
    private var isValid: Bool { !noteText.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty }
    private var characterCount: Int { noteText.count }
    private let characterLimit = 300
    
    let newExercise: MyDayNewExerciseManager
    var continueAction: (() -> ())?
    
    init(newExercise: MyDayNewExerciseManager, continueAction: (() -> ())? = nil) {
        self.newExercise = newExercise
        self.continueAction = continueAction
        self._noteText = State(initialValue: newExercise.note ?? "")
    }
    
    var body: some View {
        VStack(spacing: 0) {
            
            // ── Header ─────────────────────────────────────────────────
            VStack(spacing: 6) {
                Text("Note")
                    .font(.system(size: 20, weight: .bold))
                    .foregroundStyle(Color.primary)
                Text("Add any extra context for this set")
                    .font(.system(size: 13, weight: .regular))
                    .foregroundStyle(Color.secondary)
            }
            .padding(.top, 24)
            .padding(.bottom, 24)
            
            // ── Text editor ────────────────────────────────────────────
            VStack(alignment: .trailing, spacing: 8) {
                ZStack(alignment: .topLeading) {
                    
                    // Placeholder
                    if noteText.isEmpty {
                        Text("e.g. Felt strong, kept back straight...")
                            .font(.system(size: 15, weight: .regular))
                            .foregroundStyle(Color(UIColor.tertiaryLabel))
                            .padding(.horizontal, 14)
                            .padding(.vertical, 12)
                            .allowsHitTesting(false)
                    }
                    
                    TextEditor(text: $noteText)
                        .font(.system(size: 15, weight: .regular))
                        .focused($isFocused)
                        .scrollContentBackground(.hidden)
                        .padding(.horizontal, 10)
                        .padding(.vertical, 8)
                        .frame(minHeight: 120, maxHeight: 200)
                        .onChange(of: noteText) { _, newValue in
                            if newValue.count > characterLimit {
                                noteText = String(newValue.prefix(characterLimit))
                            }
                        }
                }
                .background(Color(UIColor.secondarySystemBackground))
                .clipShape(RoundedRectangle(cornerRadius: 14))
                .overlay {
                    RoundedRectangle(cornerRadius: 14)
                        .stroke(
                            isFocused ? Color.blue.opacity(0.5) : Color(UIColor.separator),
                            lineWidth: isFocused ? 1.5 : 0.5
                        )
                        .animation(.easeInOut(duration: 0.2), value: isFocused)
                }
                
                // Character count
                Text("\(characterCount)/\(characterLimit)")
                    .font(.system(size: 11, weight: .regular))
                    .foregroundStyle(
                        characterCount > Int(Double(characterLimit) * 0.9)
                            ? Color.orange
                            : Color(UIColor.tertiaryLabel)
                    )
            }
            .padding(.horizontal, 16)
            
            // ── Quick suggestions ──────────────────────────────────────
            if noteText.isEmpty {
                VStack(alignment: .leading, spacing: 10) {
                    Text("Suggestions")
                        .font(.system(size: 12, weight: .semibold))
                        .foregroundStyle(Color.secondary)
                    
                    ScrollView(.horizontal, showsIndicators: false) {
                        HStack(spacing: 8) {
                            ForEach(suggestions, id: \.self) { suggestion in
                                Button {
                                    noteText = suggestion
                                    isFocused = true
                                } label: {
                                    Text(suggestion)
                                        .font(.system(size: 12, weight: .medium))
                                        .foregroundStyle(Color.primary)
                                        .padding(.horizontal, 12)
                                        .padding(.vertical, 8)
                                        .background(Color(UIColor.secondarySystemBackground))
                                        .clipShape(Capsule())
                                        .overlay {
                                            Capsule()
                                                .stroke(Color(UIColor.separator), lineWidth: 0.5)
                                        }
                                }
                            }
                        }
                    }
                }
                .padding(.horizontal, 16)
                .padding(.top, 20)
                .transition(.opacity.combined(with: .move(edge: .top)))
            }
            
            Spacer()
            
            // ── Add button ─────────────────────────────────────────────
            Button {
                addAction()
            } label: {
                Text(isValid ? "Save Note" : "Enter a note")
                    .font(.system(size: 16, weight: .semibold))
                    .foregroundStyle(isValid ? Color.white : Color.secondary)
                    .frame(maxWidth: .infinity)
                    .frame(height: 52)
                    .background(
                        isValid
                            ? Color.blue
                            : Color(UIColor.secondarySystemBackground)
                    )
                    .clipShape(RoundedRectangle(cornerRadius: 14))
                    .animation(.easeInOut(duration: 0.2), value: isValid)
            }
            .disabled(!isValid)
            .padding(.horizontal, 16)
            .padding(.bottom, 16)
        }
        .onAppear {
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.3) {
                isFocused = true
            }
        }
    }
    
    // MARK: - Suggestions
    
    private var suggestions: [String] {
        [
            "Felt strong 💪",
            "Form needs work",
            "Increase weight next time",
            "Reduce weight next time",
            "Paused at bottom",
            "Slow eccentric",
            "PR attempt",
            "Fatigued",
        ]
    }
    
    // MARK: - Helpers
    
    private func addAction() {
        newExercise.setNote(noteText.trimmingCharacters(in: .whitespacesAndNewlines))
        continueAction?()
    }
}


#Preview {
    MyDayNoteSelectorView(newExercise: .init(exercise: .pressUps))
}
