//
//  WorkoutAddedConfirmationOverlay.swift
//  MyDayKit
//
//  Created by Findlay Wood on 27/06/2026.
//

import SwiftUI

struct WorkoutAddedConfirmationOverlay: View {

    var body: some View {
        VStack {
            Spacer()

            VStack(spacing: 16) {
                ZStack {
                    Circle()
                        .fill(Color.green.opacity(0.12))
                        .frame(width: 72, height: 72)
                    Image(systemName: "checkmark.circle.fill")
                        .font(.system(size: 38, weight: .medium))
                        .foregroundColor(.green)
                }

                VStack(spacing: 6) {
                    Text("Added to Today")
                        .font(.system(size: 18, weight: .bold))
                        .foregroundColor(.primary)
                    Text("Workout added to your day")
                        .font(.system(size: 14, weight: .regular))
                        .foregroundColor(.secondary)
                }
            }
            .frame(maxWidth: .infinity)
            .padding(.horizontal, 32)
            .padding(.vertical, 28)
            .background(
                RoundedRectangle(cornerRadius: 20, style: .continuous)
                    .fill(Color(UIColor.systemBackground))
                    .shadow(color: .black.opacity(0.18), radius: 24, x: 0, y: -8)
            )
            .padding(.horizontal, 20)
            .padding(.bottom, 32)
        }
    }
}

#Preview {
    ZStack {
        Color.black.opacity(0.45).ignoresSafeArea()
        WorkoutAddedConfirmationOverlay()
    }
}
