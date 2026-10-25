//
//  CustomExerciseSimilarDialog.swift
//  MyDayKit
//
//  Created by Findlay Wood on 25/10/2026.
//

import SwiftUI

/// Asked once, on the first Save, when exercises already in the list work the
/// same way (`ExerciseBodySimilarity`): use one of them, or save anyway.
///
/// A centred card on MyDay's dialog vocabulary — `WorkoutSessionDialogOverlay`'s
/// backdrop, radius and shadow — rather than a system alert, whose buttons
/// would take the system blue. **Save Anyway is the filled button**: it is a
/// nudge, not a gate, and two exercises can work the same muscles and still be
/// different exercises.
struct CustomExerciseSimilarDialog: View {

    let matches: [Exercise]
    var onUse: ((Exercise) -> Void)?
    var onSaveAnyway: (() -> Void)?
    var onDismiss: (() -> Void)?

    var body: some View {
        ZStack {
            Color.black
                .opacity(0.6)
                .ignoresSafeArea()
                .transition(.opacity)
                .onTapGesture { onDismiss?() }

            card
                .frame(maxWidth: 340)
                .padding(24)
                .transition(.scale(scale: 0.92).combined(with: .opacity))
        }
    }

    private var card: some View {
        VStack(spacing: 0) {
            VStack(spacing: 8) {
                Text("Something similar exists")
                    .font(.system(size: 18, weight: .bold))
                    .foregroundStyle(Color.primary)
                Text("These work the same muscles in the same way. Use one of them, or save yours anyway.")
                    .font(.system(size: 14))
                    .foregroundStyle(Color.secondary)
                    .fixedSize(horizontal: false, vertical: true)
            }
            .multilineTextAlignment(.center)
            .padding(.horizontal, 20)
            .padding(.top, 24)
            .padding(.bottom, 16)

            VStack(spacing: 8) {
                ForEach(matches, id: \.id) { exercise in
                    Button {
                        onUse?(exercise)
                    } label: {
                        HStack(spacing: 10) {
                            Circle()
                                .fill(exercise.category.color.opacity(0.8))
                                .frame(width: 8, height: 8)
                            Text(exercise.name)
                                .font(.system(size: 15, weight: .medium))
                                .foregroundStyle(Color.primary)
                                .lineLimit(1)
                            Spacer()
                            Text("Use")
                                .font(.system(size: 13, weight: .semibold))
                                .foregroundStyle(Color.darkColor)
                        }
                        .padding(.horizontal, 14)
                        .frame(height: 44)
                        .background(
                            RoundedRectangle(cornerRadius: 12, style: .continuous)
                                .fill(Color(UIColor.tertiarySystemGroupedBackground))
                        )
                    }
                    .buttonStyle(.plain)
                }
            }
            .padding(.horizontal, 20)
            .padding(.bottom, 16)

            VStack(spacing: 10) {
                Button {
                    onSaveAnyway?()
                } label: {
                    Text("Save Anyway")
                        .font(.system(size: 16, weight: .semibold))
                        .foregroundStyle(Color.white)
                        .frame(maxWidth: .infinity)
                        .frame(height: 52)
                        .background(Color.darkColor)
                        .clipShape(RoundedRectangle(cornerRadius: 14, style: .continuous))
                }
                .buttonStyle(.plain)

                Button {
                    onDismiss?()
                } label: {
                    Text("Keep Editing")
                        .font(.system(size: 16, weight: .semibold))
                        .foregroundStyle(Color.secondary)
                        .frame(maxWidth: .infinity)
                        .frame(height: 44)
                }
                .buttonStyle(.plain)
            }
            .padding(.horizontal, 20)
            .padding(.bottom, 16)
        }
        .background(Color(UIColor.secondarySystemGroupedBackground))
        .clipShape(RoundedRectangle(cornerRadius: 20, style: .continuous))
        .shadow(color: Color.black.opacity(0.25), radius: 24, x: 0, y: 10)
    }
}
