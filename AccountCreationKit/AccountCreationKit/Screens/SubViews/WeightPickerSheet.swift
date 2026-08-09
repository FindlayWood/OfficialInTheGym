//
//  WeightPickerSheet.swift
//  AccountCreationKit
//
//  Created by Findlay Wood on 09/08/2026.
//

import SwiftUI

/// Whole kilograms or pounds. Signup bodyweight to a decimal place is false precision, and the
/// number is going to change next week anyway.
struct WeightPickerSheet: View {

    @Binding var kilograms: Double?
    @Binding var unit: BodyWeightUnit

    @Environment(\.dismiss) private var dismiss

    @State private var kilogramSelection: Int = 75
    @State private var poundSelection: Int = 165
    @State private var hasSeeded = false

    var body: some View {
        AccountCreationPickerSheet(
            title: "Weight",
            hasValue: kilograms != nil,
            onClear: {
                kilograms = nil
                dismiss()
            },
            onDone: { dismiss() }
        ) {
            VStack(spacing: 12) {
                Picker("Unit", selection: $unit) {
                    ForEach(BodyWeightUnit.allCases) { option in
                        Text(option.label).tag(option)
                    }
                }
                .pickerStyle(.segmented)
                .tint(Color.darkColor)
                .padding(.horizontal, 20)

                switch unit {
                case .kilograms:
                    Picker("Kilograms", selection: $kilogramSelection) {
                        ForEach(BodyWeightUnit.kilogramsRange, id: \.self) { value in
                            Text("\(value) kg").tag(value)
                        }
                    }
                    .pickerStyle(.wheel)

                case .pounds:
                    Picker("Pounds", selection: $poundSelection) {
                        ForEach(BodyWeightUnit.poundsRange, id: \.self) { value in
                            Text("\(value) lbs").tag(value)
                        }
                    }
                    .pickerStyle(.wheel)
                }
            }
        }
        .onAppear(perform: seed)
        .onChange(of: kilogramSelection) { _, _ in publish() }
        .onChange(of: poundSelection) { _, _ in publish() }
        .onChange(of: unit) { _, _ in publish() }
    }

    private func seed() {
        guard !hasSeeded else { return }
        hasSeeded = true
        if let kilograms {
            kilogramSelection = Int(kilograms.rounded())
            poundSelection = BodyWeightUnit.pounds(fromKilograms: kilograms)
        }
        publish()
    }

    private func publish() {
        switch unit {
        case .kilograms:
            kilograms = Double(kilogramSelection)
        case .pounds:
            kilograms = BodyWeightUnit.kilograms(fromPounds: poundSelection)
        }
    }
}

#Preview {
    WeightPickerSheet(kilograms: .constant(80), unit: .constant(.kilograms))
}
