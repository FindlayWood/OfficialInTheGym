//
//  RatingPicker.swift
//  PerformanceKit
//
//  Created by Findlay Wood on 10/10/2026.
//
import SwiftUI

/// A 0–10 rating as a row of eleven cells, the chosen one filled `darkColor`,
/// with "Poor" and "Great" under the ends. It replaced a system segmented
/// control, which does not take the brand colour.
struct RatingPicker: View {

    @Binding var value: Int
    let title: String
    let message: String

    var body: some View {
        VStack(alignment: .leading, spacing: 10) {
            Text(message)
                .font(.system(size: 15, weight: .medium))
                .foregroundStyle(Color.primary)
            HStack(spacing: 4) {
                ForEach(0..<11, id: \.self) { number in
                    let isSelected = number == value
                    Button {
                        withAnimation(.easeInOut(duration: 0.15)) { value = number }
                    } label: {
                        Text("\(number)")
                            .font(.system(size: 14, weight: .semibold))
                            .foregroundStyle(isSelected ? Color.white : Color.primary)
                            .frame(maxWidth: .infinity)
                            .frame(height: 38)
                            .background(
                                RoundedRectangle(cornerRadius: 8, style: .continuous)
                                    .fill(isSelected ? Color.darkColor : Color(.tertiarySystemBackground))
                            )
                    }
                    .buttonStyle(.plain)
                    .accessibilityLabel("\(title) \(number)")
                }
            }
            HStack {
                Text("Poor")
                Spacer()
                Text("Great")
            }
            .font(.system(size: 12))
            .foregroundStyle(Color.secondary)
        }
        .padding(16)
        .performanceCard()
    }
}
