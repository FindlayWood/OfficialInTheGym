//
//  WeightLogSheet.swift
//  ProfileKit
//
//  Created by Findlay Wood on 03/10/2026.
//
import SwiftUI

/// Logs today's weight: a unit switch, then a whole-number wheel and a tenths
/// wheel. It opens on the latest logged weight, since the next reading is
/// almost always within a kilogram of the last.
///
/// Unlike the height and date-of-birth sheets, nothing binds live. "Log" is the
/// action, and swiping the sheet away logs nothing, because a weight log is a
/// record made on purpose, not a field being adjusted.
struct WeightLogSheet: View {

    let initialKilograms: Double?
    let initialUnit: ProfileWeightUnit
    let onLog: (Double, ProfileWeightUnit) -> Void

    @Environment(\.dismiss) private var dismiss

    @State private var unit: ProfileWeightUnit = .kilograms
    @State private var whole: Int = 75
    @State private var tenths: Int = 0
    @State private var hasSeeded = false

    var body: some View {
        ProfilePickerSheet(
            title: "Log Weight",
            hasValue: false,
            actionTitle: "Log",
            onAction: {
                onLog(unit.kilograms(from: value), unit)
                dismiss()
            }
        ) {
            VStack(spacing: 12) {
                Picker("Unit", selection: $unit) {
                    ForEach(ProfileWeightUnit.allCases) { option in
                        Text(option.label).tag(option)
                    }
                }
                .pickerStyle(.segmented)
                .padding(.horizontal, 20)

                HStack(spacing: 0) {
                    Picker("Whole", selection: $whole) {
                        ForEach(unit.wholeRange, id: \.self) { value in
                            Text("\(value)").tag(value)
                        }
                    }
                    .pickerStyle(.wheel)

                    Picker("Tenths", selection: $tenths) {
                        ForEach(0...9, id: \.self) { value in
                            Text(".\(value) \(unit.label)").tag(value)
                        }
                    }
                    .pickerStyle(.wheel)
                }
            }
        }
        .onAppear(perform: seed)
        .onChange(of: unit) { oldUnit, newUnit in
            // Converts rather than resets, as the signup sheets do.
            setWheels(to: newUnit.value(fromKilograms: oldUnit.kilograms(from: value)), in: newUnit)
        }
    }

    private var value: Double {
        Double(whole) + Double(tenths) / 10
    }

    private func seed() {
        guard !hasSeeded else { return }
        hasSeeded = true
        unit = initialUnit
        if let initialKilograms {
            setWheels(to: initialUnit.value(fromKilograms: initialKilograms), in: initialUnit)
        } else {
            whole = initialUnit == .kilograms ? 75 : 165
        }
    }

    private func setWheels(to value: Double, in unit: ProfileWeightUnit) {
        let rounded = (value * 10).rounded() / 10
        let clamped = min(max(rounded, Double(unit.wholeRange.lowerBound)), Double(unit.wholeRange.upperBound))
        whole = Int(clamped)
        tenths = Int(((clamped - Double(Int(clamped))) * 10).rounded()) % 10
    }
}
