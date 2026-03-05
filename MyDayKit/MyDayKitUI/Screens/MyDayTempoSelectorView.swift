//
//  MyDayTempoSelectorView.swift
//  MyDayKit
//
//  Created by Findlay Wood on 31/10/2025.
//

import SwiftUI

struct MyDayTempoSelectorView: View {
    
    @State private var tempo: Tempo
    
    private var isValidSelection: Bool {
        tempo.eccentric > 0 || tempo.eccentricHold > 0 || tempo.concentric > 0 || tempo.concentricHold > 0
    }
    
    private var tempoString: String {
        "\(tempo.eccentric)–\(tempo.eccentricHold)–\(tempo.concentric)–\(tempo.concentricHold)"
    }
    
    let newExercise: MyDayNewExerciseManager
    var continueAction: (() -> ())?
    
    init(newExercise: MyDayNewExerciseManager, continueAction: (() -> ())? = nil) {
        self.newExercise = newExercise
        self.continueAction = continueAction
        self._tempo = State(initialValue: newExercise.tempo ?? .init())
    }
    
    var body: some View {
        VStack(spacing: 0) {
            
            // ── Header ─────────────────────────────────────────────────
            VStack(spacing: 6) {
                Text("Tempo")
                    .font(.system(size: 20, weight: .bold))
                    .foregroundStyle(Color.primary)
                
                Text("Down · Hold · Up · Hold")
                    .font(.system(size: 13, weight: .regular))
                    .foregroundStyle(Color.secondary)
            }
            .padding(.top, 24)
            .padding(.bottom, 20)
            
            // ── Live tempo preview ─────────────────────────────────────
            HStack(alignment: .lastTextBaseline, spacing: 4) {
                Text(tempoString)
                    .font(.system(size: 36, weight: .bold, design: .rounded))
                    .foregroundStyle(isValidSelection ? Color.primary : Color(UIColor.tertiaryLabel))
                    .contentTransition(.numericText())
                    .animation(.easeInOut(duration: 0.15), value: tempo.eccentric)
                    .animation(.easeInOut(duration: 0.15), value: tempo.eccentricHold)
                    .animation(.easeInOut(duration: 0.15), value: tempo.concentric)
                    .animation(.easeInOut(duration: 0.15), value: tempo.concentricHold)
                
                Text("sec")
                    .font(.system(size: 16, weight: .medium))
                    .foregroundStyle(Color.secondary)
                    .padding(.bottom, 4)
            }
            .padding(.vertical, 16)
            .frame(maxWidth: .infinity)
            .background(Color(UIColor.secondarySystemBackground))
            .clipShape(RoundedRectangle(cornerRadius: 14))
            .padding(.horizontal, 16)
            .padding(.bottom, 28)
            
            // ── Tempo columns ──────────────────────────────────────────
            HStack(spacing: 10) {
                tempoColumn(
                    label: "Down",
                    sublabel: "Eccentric",
                    value: $tempo.eccentric
                )
                tempoColumn(
                    label: "Hold",
                    sublabel: "Bottom",
                    value: $tempo.eccentricHold
                )
                tempoColumn(
                    label: "Up",
                    sublabel: "Concentric",
                    value: $tempo.concentric
                )
                tempoColumn(
                    label: "Hold",
                    sublabel: "Top",
                    value: $tempo.concentricHold
                )
            }
            .padding(.horizontal, 16)
            
            // ── What is tempo? ─────────────────────────────────────────
            HStack(spacing: 6) {
                Image(systemName: "info.circle")
                    .font(.system(size: 11))
                    .foregroundStyle(Color.secondary)
                Text("Each number is the seconds spent in that phase.")
                    .font(.system(size: 11, weight: .regular))
                    .foregroundStyle(Color.secondary)
                Spacer()
            }
            .padding(.horizontal, 20)
            .padding(.top, 16)
            
            Spacer()
            
            // ── Add button ─────────────────────────────────────────────
            Button {
                addAction()
            } label: {
                Text(isValidSelection ? "Add Tempo \(tempoString)" : "Select a tempo")
                    .font(.system(size: 16, weight: .semibold))
                    .foregroundStyle(isValidSelection ? Color.white : Color.secondary)
                    .frame(maxWidth: .infinity)
                    .frame(height: 52)
                    .background(
                        isValidSelection
                            ? Color.blue
                            : Color(UIColor.secondarySystemBackground)
                    )
                    .clipShape(RoundedRectangle(cornerRadius: 14))
                    .animation(.easeInOut(duration: 0.2), value: isValidSelection)
            }
            .disabled(!isValidSelection)
            .padding(.horizontal, 16)
            .padding(.bottom, 16)
        }
    }
    
    // MARK: - Tempo Column
    
    @ViewBuilder
    private func tempoColumn(label: String, sublabel: String, value: Binding<Int>) -> some View {
        VStack(spacing: 10) {
            
            // Labels
            VStack(spacing: 2) {
                Text(label)
                    .font(.system(size: 13, weight: .semibold))
                    .foregroundStyle(Color.primary)
                Text(sublabel)
                    .font(.system(size: 10, weight: .regular))
                    .foregroundStyle(Color.secondary)
            }
            
            // + button
            Button {
                value.wrappedValue += 1
            } label: {
                ZStack {
                    RoundedRectangle(cornerRadius: 10)
                        .fill(Color.blue.opacity(0.1))
                        .frame(height: 44)
                    Image(systemName: "plus")
                        .font(.system(size: 16, weight: .semibold))
                        .foregroundStyle(Color.blue)
                }
            }
            
            // Value
            Text("\(value.wrappedValue)")
                .font(.system(size: 28, weight: .bold, design: .rounded))
                .foregroundStyle(value.wrappedValue > 0 ? Color.primary : Color(UIColor.tertiaryLabel))
                .frame(height: 36)
                .contentTransition(.numericText())
                .animation(.easeInOut(duration: 0.15), value: value.wrappedValue)
            
            // - button
            Button {
                value.wrappedValue = max(0, value.wrappedValue - 1)
            } label: {
                ZStack {
                    RoundedRectangle(cornerRadius: 10)
                        .fill(value.wrappedValue > 0 ? Color.red.opacity(0.1) : Color(UIColor.tertiarySystemBackground))
                        .frame(height: 44)
                    Image(systemName: "minus")
                        .font(.system(size: 16, weight: .semibold))
                        .foregroundStyle(value.wrappedValue > 0 ? Color.red : Color(UIColor.tertiaryLabel))
                }
            }
            .disabled(value.wrappedValue == 0)
        }
        .padding(.horizontal, 6)
        .padding(.vertical, 12)
        .frame(maxWidth: .infinity)
        .background(Color(UIColor.secondarySystemBackground))
        .clipShape(RoundedRectangle(cornerRadius: 14))
    }
    
    private func addAction() {
        newExercise.setTempo(tempo)
        continueAction?()
    }
}

#Preview {
    MyDayTempoSelectorView(newExercise: .init(exercise: .squat))
}

struct Tempo: Codable {
    var eccentric: Int
    var eccentricHold: Int
    var concentric: Int
    var concentricHold: Int
    
    init() {
        self.eccentric = 0
        self.eccentricHold = 0
        self.concentric = 0
        self.concentricHold = 0
    }
}
