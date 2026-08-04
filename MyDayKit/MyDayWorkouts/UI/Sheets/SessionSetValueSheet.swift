//
//  SessionSetValueSheet.swift
//  MyDayKit
//
//  Created by Findlay Wood on 01/08/2026.
//

import SwiftUI

/// Enters one value of a set on the custom number pad, so nothing in an active
/// session depends on the system keyboard. Binds live — "Done" only dismisses.
struct SessionSetValueSheet: View {

    let measure: SessionSetMeasure
    let exerciseName: String
    let setNumber: Int
    let unitLabel: String?
    let targetSummary: String?

    @Binding var value: String

    /// Weight only — the unit actually lifted. `nil` for every other measure,
    /// whose unit comes from the template. Restricted to `WeightUnit.loggable`:
    /// the percentage and `Max` cases describe a target, not a performed load.
    var weightUnit: Binding<WeightUnit>?

    @Environment(\.dismiss) private var dismiss

    private var hasInput: Bool { !value.isEmpty }

    /// A bodyweight set is stated by its unit alone, so there is nothing to type.
    private var takesNumber: Bool {
        weightUnit.map { $0.wrappedValue.carriesValue } ?? true
    }

    private var decimalDisabled: Bool {
        !measure.allowsDecimal || value.isEmpty || value.contains(".")
    }

    var body: some View {
        VStack(spacing: 0) {
            header
            valueDisplay

            if let weightUnit {
                unitPicker(weightUnit)
            }

            if let targetSummary, takesNumber {
                targetReference(targetSummary)
            }

            if takesNumber {
                Divider()
                    .padding(.top, 16)

                CustomNumberPad(
                    showingDecimalPoint: measure.allowsDecimal,
                    decimalDisabled: decimalDisabled,
                    backspaceDisabled: value.isEmpty,
                    zeroDisabled: value.isEmpty,
                    decimalSelected: { value.append(".") },
                    selection: { value.append("\($0)") },
                    backspace: { value.removeLast() }
                )
            }

            Spacer(minLength: 0)

            doneButton
        }
    }

    // MARK: - Header

    private var header: some View {
        VStack(spacing: 4) {
            Text(exerciseName)
                .font(.system(size: 13, weight: .semibold))
                .foregroundStyle(Color.secondary)
                .lineLimit(1)
            Text("\(measure.title) · Set \(setNumber)")
                .font(.system(size: 20, weight: .bold))
                .foregroundStyle(Color.primary)
        }
        .frame(maxWidth: .infinity)
        .padding(.top, 24)
        .padding(.bottom, 20)
    }

    // MARK: - Value Display

    private var valueDisplay: some View {
        HStack(alignment: .lastTextBaseline, spacing: 6) {
            Text(displayValue)
                .font(.system(size: 56, weight: .bold, design: .rounded))
                .foregroundStyle(showsPlaceholder ? Color(UIColor.tertiaryLabel) : Color.primary)
                .contentTransition(.numericText())
                .animation(.easeInOut(duration: 0.15), value: value)
                .lineLimit(1)
                .minimumScaleFactor(0.6)

            if let unitLabel, hasInput, takesNumber {
                Text(unitLabel)
                    .font(.system(size: 20, weight: .semibold))
                    .foregroundStyle(Color.secondary)
                    .padding(.bottom, 8)
                    .transition(.opacity)
            }
        }
        .frame(maxWidth: .infinity)
        .padding(.vertical, 20)
        .background(Color(UIColor.secondarySystemBackground))
        .clipShape(RoundedRectangle(cornerRadius: 14))
        .padding(.horizontal, 16)
        .animation(.easeInOut(duration: 0.15), value: hasInput)
    }

    private var displayValue: String {
        guard takesNumber else { return weightUnit?.wrappedValue.rawValue ?? "–" }
        return hasInput ? value : "–"
    }

    private var showsPlaceholder: Bool { takesNumber && !hasInput }

    // MARK: - Unit Picker

    private func unitPicker(_ unit: Binding<WeightUnit>) -> some View {
        HStack(spacing: 8) {
            ForEach(WeightUnit.loggable, id: \.self) { option in
                Button {
                    withAnimation(.easeInOut(duration: 0.15)) {
                        unit.wrappedValue = option
                        // A bodyweight set carries no number, so anything
                        // already typed would be stored and never rendered.
                        if !option.carriesValue { value = "" }
                    }
                } label: {
                    Text(option.rawValue)
                        .font(.system(size: 14, weight: .semibold))
                        .foregroundStyle(unit.wrappedValue == option ? Color.white : Color.secondary)
                        .frame(maxWidth: .infinity)
                        .frame(height: 40)
                        .background(
                            RoundedRectangle(cornerRadius: 12)
                                .fill(
                                    unit.wrappedValue == option
                                        ? Color.darkColor
                                        : Color(UIColor.secondarySystemBackground)
                                )
                        )
                }
                .buttonStyle(.plain)
            }
        }
        .padding(.horizontal, 16)
        .padding(.top, 12)
    }

    // MARK: - Target Reference

    private func targetReference(_ summary: String) -> some View {
        HStack(spacing: 6) {
            Image(systemName: "target")
                .font(.system(size: 12, weight: .medium))
                .foregroundStyle(Color.secondary)
            Text("Target")
                .font(.system(size: 13, weight: .semibold))
                .foregroundStyle(Color.secondary)
            Text(summary)
                .font(.system(size: 13, weight: .medium))
                .foregroundStyle(Color.primary)
        }
        .frame(maxWidth: .infinity)
        .padding(.top, 12)
    }

    // MARK: - Done

    private var doneButton: some View {
        Button {
            dismiss()
        } label: {
            Text("Done")
                .font(.system(size: 16, weight: .semibold))
                .foregroundStyle(Color.white)
                .frame(maxWidth: .infinity)
                .frame(height: 52)
                .background(Color.darkColor)
                .clipShape(RoundedRectangle(cornerRadius: 14))
        }
        .padding(.horizontal, 24)
        .padding(.bottom, 16)
    }
}

// MARK: - Preview

#Preview {
    @Previewable @State var value = "80"
    @Previewable @State var unit: WeightUnit = .kg

    Color.darkColor
        .sheet(isPresented: .constant(true)) {
            SessionSetValueSheet(
                measure: .weight,
                exerciseName: "Bench Press",
                setNumber: 2,
                unitLabel: unit.rawValue,
                targetSummary: "80 kg",
                value: $value,
                weightUnit: $unit
            )
            .presentationDetents([.height(620)])
        }
}
