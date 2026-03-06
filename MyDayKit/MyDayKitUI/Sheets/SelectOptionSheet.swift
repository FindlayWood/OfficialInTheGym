//
//  SelectOptionSheet.swift
//  MyDayKit
//
//  Created by Findlay Wood on 12/01/2026.
//

import SwiftUI

struct SelectOptionSheet: View {
    
    var exerciseSelected: (() -> ())?
    var fitnessSelected: (() -> ())?
    var sportSelected: (() -> ())?
    
    var body: some View {
        VStack(spacing: 0) {
            
            // ── Title ──────────────────────────────────────────────────
            HStack {
                Text("What are you adding?")
                    .font(.system(size: 20, weight: .bold))
                    .foregroundStyle(Color.primary)
                Spacer()
            }
            .padding(.horizontal, 20)
            .padding(.bottom, 20)
            
            // ── Options ────────────────────────────────────────────────
            VStack(spacing: 10) {
                optionRow(
                    title: "Exercise",
                    subtitle: "Reps, sets, weight and more",
                    icon: "dumbbell.fill",
                    color: Color.blue
                ) {
                    exerciseSelected?()
                }
                
                optionRow(
                    title: "Fitness",
                    subtitle: "Cardio, running, cycling",
                    icon: "figure.run",
                    color: Color.green
                ) {
                    fitnessSelected?()
                }
                
                optionRow(
                    title: "Sport",
                    subtitle: "Games, training sessions",
                    icon: "sportscourt.fill",
                    color: Color.orange
                ) {
                    sportSelected?()
                }
            }
            .padding(.horizontal, 20)
            .padding(.bottom, 24)
        }
        .presentationDragIndicator(.hidden)
        .presentationCornerRadius(28)
    }
    
    // MARK: - Option Row
    
    @ViewBuilder
    private func optionRow(
        title: String,
        subtitle: String,
        icon: String,
        color: Color,
        action: @escaping () -> Void
    ) -> some View {
        Button(action: action) {
            HStack(spacing: 14) {
                ZStack {
                    RoundedRectangle(cornerRadius: 10)
                        .fill(color.opacity(0.12))
                        .frame(width: 44, height: 44)
                    Image(systemName: icon)
                        .font(.system(size: 18, weight: .semibold))
                        .foregroundStyle(color)
                }
                
                VStack(alignment: .leading, spacing: 2) {
                    Text(title)
                        .font(.system(size: 15, weight: .semibold))
                        .foregroundStyle(Color.primary)
                    Text(subtitle)
                        .font(.system(size: 12, weight: .regular))
                        .foregroundStyle(Color.secondary)
                }
                
                Spacer()
                
                Image(systemName: "chevron.right")
                    .font(.system(size: 13, weight: .semibold))
                    .foregroundStyle(Color(UIColor.tertiaryLabel))
            }
            .padding(.horizontal, 14)
            .padding(.vertical, 12)
            .background(Color(UIColor.secondarySystemBackground))
            .clipShape(RoundedRectangle(cornerRadius: 14))
        }
        .buttonStyle(.plain)
    }
}
#Preview {
    SelectOptionSheet()
}
