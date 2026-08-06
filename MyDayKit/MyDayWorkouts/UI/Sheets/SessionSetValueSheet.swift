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

    /// The unit actually lifted. Restricted to `WeightUnit.loggable`: the
    /// percentage and `Max` cases describe a target, not a performed load.
    var weightUnit: Binding<WeightUnit>?

    /// The unit the distance was covered in — m / km / mi, the same three
    /// `MyDayWorkoutBuilderDistanceScreen` offers.
    var distanceUnit: Binding<DistanceUnit>?

    /// Whether the number on the pad means seconds or minutes. Entry only: the
    /// value is converted to seconds before it leaves this sheet.
    var timeUnit: Binding<SessionTimeUnit>?

    /// What the entered value works out to, when that is not simply the number
    /// typed — "3 min" resolving to "3m 0s". `nil` hides the line.
    var resolvedSummary: String?

    @Environment(\.dismiss) private var dismiss

    private var hasInput: Bool { !value.isEmpty }

    /// A bodyweight set is stated by its unit alone, so there is nothing to type.
    private var takesNumber: Bool {
        selectedOption.map(\.carriesValue) ?? true
    }

    private var decimalDisabled: Bool {
        !measure.allowsDecimal || value.isEmpty || value.contains(".")
    }

    // MARK: - Unit Options

    /// The measure's units, flattened so one picker can draw any of them.
    private var unitOptions: [SessionSetUnitOption] {
        if weightUnit != nil {
            return WeightUnit.loggable.map {
                SessionSetUnitOption(id: $0.rawValue, label: $0.rawValue, carriesValue: $0.carriesValue)
            }
        }
        if distanceUnit != nil {
            return DistanceUnit.allCases.map {
                SessionSetUnitOption(id: $0.rawValue, label: $0.rawValue, fullName: $0.fullName)
            }
        }
        if timeUnit != nil {
            return SessionTimeUnit.allCases.map {
                SessionSetUnitOption(id: $0.rawValue, label: $0.rawValue, fullName: $0.fullName)
            }
        }
        return []
    }

    private var selectedOption: SessionSetUnitOption? {
        guard let id = selectedUnitId else { return nil }
        return unitOptions.first { $0.id == id }
    }

    private var selectedUnitId: String? {
        weightUnit?.wrappedValue.rawValue
            ?? distanceUnit?.wrappedValue.rawValue
            ?? timeUnit?.wrappedValue.rawValue
    }

    private func selectUnit(_ option: SessionSetUnitOption) {
        if let weightUnit, let unit = WeightUnit(rawValue: option.id) {
            weightUnit.wrappedValue = unit
        } else if let distanceUnit, let unit = DistanceUnit(rawValue: option.id) {
            distanceUnit.wrappedValue = unit
        } else if let timeUnit, let unit = SessionTimeUnit(rawValue: option.id) {
            timeUnit.wrappedValue = unit
        }

        // A unit that states the set on its own carries no number, so anything
        // already typed would be stored and never rendered.
        if !option.carriesValue { value = "" }
    }

    var body: some View {
        VStack(spacing: 0) {
            header
            valueDisplay

            if !unitOptions.isEmpty {
                unitPicker
            }

            if let resolvedSummary, takesNumber, hasInput {
                resolvedReference(resolvedSummary)
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
        guard takesNumber else { return selectedOption?.label ?? "–" }
        return hasInput ? value : "–"
    }

    private var showsPlaceholder: Bool { takesNumber && !hasInput }

    // MARK: - Unit Picker

    /// One picker for whichever unit the measure has. Laid out like
    /// `MyDayWorkoutBuilderDistanceScreen`'s — short label over the full word —
    /// so choosing "km" in a session looks like choosing "km" in the builder.
    /// Options with no `fullName` (the weight units) keep the single-line
    /// button the weight picker has always had.
    private var unitPicker: some View {
        HStack(spacing: 8) {
            ForEach(unitOptions) { option in
                let isSelected = option.id == selectedUnitId

                Button {
                    withAnimation(.easeInOut(duration: 0.15)) {
                        selectUnit(option)
                    }
                } label: {
                    VStack(spacing: 3) {
                        Text(option.label)
                            .font(.system(size: 14, weight: .semibold))
                            .foregroundStyle(isSelected ? Color.white : Color.secondary)

                        if let fullName = option.fullName {
                            Text(fullName)
                                .font(.system(size: 10, weight: .regular))
                                .foregroundStyle(isSelected ? Color.white.opacity(0.7) : Color.secondary)
                                .lineLimit(1)
                                .minimumScaleFactor(0.8)
                        }
                    }
                    .frame(maxWidth: .infinity)
                    .frame(height: option.fullName == nil ? 40 : 52)
                    .background(
                        RoundedRectangle(cornerRadius: 12)
                            .fill(isSelected ? Color.darkColor : Color(UIColor.secondarySystemBackground))
                    )
                }
                .buttonStyle(.plain)
            }
        }
        .padding(.horizontal, 16)
        .padding(.top, 12)
    }

    // MARK: - Resolved Reference

    /// What the entry works out to, when the unit means the stored value is not
    /// the number typed — "3 min" is stored as 180 seconds, so the sheet says
    /// "3m 0s" rather than leaving the user to trust the conversion.
    private func resolvedReference(_ summary: String) -> some View {
        HStack(spacing: 6) {
            Image(systemName: "equal.circle")
                .font(.system(size: 12, weight: .medium))
                .foregroundStyle(Color.secondary)
            Text(summary)
                .font(.system(size: 13, weight: .semibold))
                .foregroundStyle(Color.primary)
        }
        .frame(maxWidth: .infinity)
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
