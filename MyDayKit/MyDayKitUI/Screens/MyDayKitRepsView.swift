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
    
    private var hasInput: Bool { !stringInput.isEmpty }
    
    var body: some View {
        VStack(spacing: 0) {
            
            // ── Rep display ────────────────────────────────────────────
            VStack(spacing: 8) {
                Text(exercise.exercise.name)
                    .font(.system(size: 13, weight: .semibold))
                    .foregroundStyle(Color.secondary)
                    .multilineTextAlignment(.center)
                
                HStack(alignment: .lastTextBaseline, spacing: 6) {
                    Text(hasInput ? "\(reps)" : "–")
                        .font(.system(size: 72, weight: .bold, design: .rounded))
                        .foregroundStyle(hasInput ? Color.primary : Color(UIColor.tertiaryLabel))
                        .contentTransition(.numericText())
                        .animation(.easeInOut(duration: 0.15), value: reps)
                    
                    if hasInput {
                        Text(reps == 1 ? "rep" : "reps")
                            .font(.system(size: 20, weight: .semibold))
                            .foregroundStyle(Color.secondary)
                            .padding(.bottom, 8)
                            .transition(.opacity.combined(with: .scale(scale: 0.8)))
                    }
                }
                .frame(maxWidth: .infinity)
                .animation(.easeInOut(duration: 0.15), value: hasInput)
                
                // Each side toggle
                Button {
                    exercise.eachSide.toggle()
                } label: {
                    HStack(spacing: 8) {
                        ZStack {
                            RoundedRectangle(cornerRadius: 6)
                                .fill(exercise.eachSide ? Color.darkColor.opacity(0.12) : Color(UIColor.tertiarySystemBackground))
                                .frame(width: 28, height: 28)
                            Image(systemName: exercise.eachSide ? "checkmark" : "arrow.left.arrow.right")
                                .font(.system(size: 12, weight: .semibold))
                                .foregroundStyle(exercise.eachSide ? Color.darkColor : Color.secondary)
                        }
                        
                        Text("Each side")
                            .font(.system(size: 14, weight: .medium))
                            .foregroundStyle(Color.primary)
                        
                        if exercise.eachSide {
                            Text("· \(reps * 2) total reps")
                                .font(.system(size: 13, weight: .regular))
                                .foregroundStyle(Color.secondary)
                                .transition(.opacity.combined(with: .move(edge: .leading)))
                        }
                        
                        Spacer()
                    }
                    .padding(.horizontal, 14)
                    .padding(.vertical, 10)
                    .background(Color(UIColor.secondarySystemBackground))
                    .clipShape(RoundedRectangle(cornerRadius: 12))
                    .animation(.easeInOut(duration: 0.2), value: exercise.eachSide)
                }
                .buttonStyle(.plain)
            }
            .padding(.horizontal, 24)
            .padding(.top, 24)
            .padding(.bottom, 20)
            
            Divider()
                .padding(.bottom, 8)
            
            // ── Number pad ─────────────────────────────────────────────
            CustomNumberPad(
                backspaceDisabled: stringInput.isEmpty,
                zeroDisabled: stringInput.isEmpty,
                selection: { number in
                    stringInput.append("\(number)")
                    reps = Int(stringInput) ?? 1
                },
                backspace: {
                    stringInput.removeLast()
                    reps = Int(stringInput) ?? 1
                }
            )
            
            // ── Add button ─────────────────────────────────────────────
            Button {
                addAction()
            } label: {
                Text(hasInput ? "Add \(reps) \(reps == 1 ? "rep" : "reps")" : "Enter reps")
                    .font(.system(size: 16, weight: .semibold))
                    .foregroundStyle(hasInput ? Color.white : Color.secondary)
                    .frame(maxWidth: .infinity)
                    .frame(height: 52)
                    .background(hasInput ? Color.darkColor : Color(UIColor.secondarySystemBackground))
                    .clipShape(RoundedRectangle(cornerRadius: 14))
                    .animation(.easeInOut(duration: 0.2), value: hasInput)
            }
            .disabled(!hasInput)
            .padding(.horizontal, 24)
            .padding(.bottom, 16)
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
            deleter: PreviewMyDayDeleter(),
            wellnessSaver: PreviewMyDaySaver(),
            rpeSaver: PreviewMyDaySaver(),
            workoutSaver: PreviewMyDaySaver()
        ),
        exercise: MyDayNewExerciseManager(exercise: .pressUps)
    )
}
