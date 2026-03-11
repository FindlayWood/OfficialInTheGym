//
//  SportNoteSelectorView.swift
//  MyDayKit
//
//  Created by Findlay Wood on 11/03/2026.
//

import SwiftUI

struct SportNoteSelectorView: View {
    
    @ObservedObject var manager: MyDayNewSportManager
    @FocusState private var isFocused: Bool
    @State private var noteText: String
    
    var continueAction: (() -> ())?
    
    private var isValid: Bool {
        !noteText.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty
    }
    
    private let characterLimit = 300
    
    init(manager: MyDayNewSportManager, continueAction: (() -> ())? = nil) {
        self.manager = manager
        self.continueAction = continueAction
        self._noteText = State(initialValue: manager.note ?? "")
    }
    
    var body: some View {
        VStack(spacing: 0) {
            RoundedRectangle(cornerRadius: 3)
                .fill(Color(UIColor.tertiaryLabel))
                .frame(width: 36, height: 4)
                .padding(.top, 12)
                .padding(.bottom, 20)
            
            VStack(spacing: 6) {
                Text("Note")
                    .font(.system(size: 20, weight: .bold))
                    .foregroundStyle(Color.primary)
                Text("Add any extra context for this session")
                    .font(.system(size: 13, weight: .regular))
                    .foregroundStyle(Color.secondary)
            }
            .padding(.bottom, 20)
            
            VStack(alignment: .trailing, spacing: 8) {
                ZStack(alignment: .topLeading) {
                    if noteText.isEmpty {
                        Text("e.g. Great game, felt sharp in the second half...")
                            .font(.system(size: 15))
                            .foregroundStyle(Color(UIColor.tertiaryLabel))
                            .padding(.horizontal, 14)
                            .padding(.vertical, 12)
                            .allowsHitTesting(false)
                    }
                    TextEditor(text: $noteText)
                        .font(.system(size: 15))
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
                            isFocused ? manager.sport.color.opacity(0.5) : Color(UIColor.separator),
                            lineWidth: isFocused ? 1.5 : 0.5
                        )
                        .animation(.easeInOut(duration: 0.2), value: isFocused)
                }
                
                Text("\(noteText.count)/\(characterLimit)")
                    .font(.system(size: 11))
                    .foregroundStyle(
                        noteText.count > Int(Double(characterLimit) * 0.9)
                            ? Color.orange
                            : Color(UIColor.tertiaryLabel)
                    )
            }
            .padding(.horizontal, 16)
            
            Spacer()
            
            Button {
                manager.note = noteText.trimmingCharacters(in: .whitespacesAndNewlines)
                continueAction?()
            } label: {
                Text(isValid ? "Save Note" : "Enter a note")
                    .font(.system(size: 16, weight: .semibold))
                    .foregroundStyle(isValid ? Color.white : Color.secondary)
                    .frame(maxWidth: .infinity)
                    .frame(height: 52)
                    .background(isValid ? manager.sport.color : Color(UIColor.secondarySystemBackground))
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
}

#Preview {
    SportNoteSelectorView(manager: MyDayNewSportManager(sport: .americanFootball))
}
