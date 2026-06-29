//
//  WorkoutExerciseRPESheet.swift
//  MyDayKit
//
//  Created by Findlay Wood on 29/06/2026.
//

import SwiftUI

struct WorkoutExerciseRPESheet: View {

    let exerciseName: String
    let currentRPE: Int?
    var onSelect: ((Int) -> Void)?

    @State private var flashingValue: Int?

    var body: some View {
        VStack(alignment: .leading, spacing: 0) {
            HStack {
                VStack(alignment: .leading, spacing: 3) {
                    Text(exerciseName)
                        .font(.system(size: 16, weight: .semibold))
                        .foregroundStyle(Color.primary)
                    Text("Rate of Perceived Exertion")
                        .font(.system(size: 13))
                        .foregroundStyle(Color.secondary)
                }
                Spacer()
                if let rpe = currentRPE {
                    Text("\(rpe)")
                        .font(.system(size: 22, weight: .bold))
                        .foregroundStyle(rpeColor(rpe))
                }
            }
            .padding(.horizontal, 20)
            .padding(.top, 20)
            .padding(.bottom, 16)

            Divider()

            LazyVGrid(columns: Array(repeating: GridItem(.flexible(), spacing: 8), count: 5), spacing: 8) {
                ForEach(1...10, id: \.self) { value in
                    let flashing = flashingValue == value
                    let selected = currentRPE == value && flashingValue == nil
                    let highlighted = flashing || selected
                    let color = rpeColor(value)
                    Button {
                        guard flashingValue == nil else { return }
                        flashingValue = value
                        Task {
                            try? await Task.sleep(nanoseconds: 300_000_000)
                            onSelect?(value)
                        }
                    } label: {
                        Text("\(value)")
                            .font(.system(size: 17, weight: .bold))
                            .foregroundStyle(highlighted ? .white : color)
                            .frame(maxWidth: .infinity)
                            .frame(height: 52)
                            .background(
                                RoundedRectangle(cornerRadius: 14)
                                    .fill(highlighted ? color : Color(UIColor.secondarySystemBackground))
                            )
                    }
                    .buttonStyle(.plain)
                    .scaleEffect(highlighted ? 1.05 : 1.0)
                    .animation(.spring(response: 0.2, dampingFraction: 0.7), value: highlighted)
                }
            }
            .padding(.horizontal, 20)
            .padding(.vertical, 16)

            Spacer()
        }
    }

    private func rpeColor(_ value: Int) -> Color {
        switch value {
        case 1:  return Color(red: 0.13, green: 0.75, blue: 0.35)
        case 2:  return Color(red: 0.35, green: 0.78, blue: 0.20)
        case 3:  return Color(red: 0.58, green: 0.80, blue: 0.10)
        case 4:  return Color(red: 0.80, green: 0.80, blue: 0.00)
        case 5:  return Color(red: 0.95, green: 0.70, blue: 0.00)
        case 6:  return Color(red: 1.00, green: 0.55, blue: 0.00)
        case 7:  return Color(red: 1.00, green: 0.38, blue: 0.00)
        case 8:  return Color(red: 0.95, green: 0.20, blue: 0.00)
        case 9:  return Color(red: 0.82, green: 0.08, blue: 0.00)
        case 10: return Color(red: 0.65, green: 0.00, blue: 0.00)
        default: return Color.gray
        }
    }
}

#Preview {
    WorkoutExerciseRPESheet(
        exerciseName: "Bench Press",
        currentRPE: 7
    )
    .presentationDetents([.height(260)])
}
