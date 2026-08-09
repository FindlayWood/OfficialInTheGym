//
//  HeightPickerSheet.swift
//  AccountCreationKit
//
//  Created by Findlay Wood on 09/08/2026.
//

import SwiftUI

/// Wheels rather than a keyboard: nothing invalid can be entered, there is no keyboard to dismiss,
/// and no validation to write. Switching unit **keeps the height** — it converts rather than
/// clearing, because by the time you notice the unit is wrong you have already dialled a number in.
struct HeightPickerSheet: View {

    @Binding var centimetres: Double?
    @Binding var unit: HeightUnit

    @Environment(\.dismiss) private var dismiss

    @State private var centimetreSelection: Int = 175
    @State private var feetSelection: Int = 5
    @State private var inchesSelection: Int = 9
    @State private var hasSeeded = false

    var body: some View {
        AccountCreationPickerSheet(
            title: "Height",
            hasValue: centimetres != nil,
            onClear: {
                centimetres = nil
                dismiss()
            },
            onDone: { dismiss() }
        ) {
            VStack(spacing: 12) {
                Picker("Unit", selection: $unit) {
                    ForEach(HeightUnit.allCases) { option in
                        Text(option.label).tag(option)
                    }
                }
                .pickerStyle(.segmented)
                .tint(Color.darkColor)
                .padding(.horizontal, 20)

                switch unit {
                case .centimetres:
                    Picker("Centimetres", selection: $centimetreSelection) {
                        ForEach(HeightUnit.minimumCentimetres...HeightUnit.maximumCentimetres, id: \.self) { value in
                            Text("\(value) cm").tag(value)
                        }
                    }
                    .pickerStyle(.wheel)

                case .feetInches:
                    HStack(spacing: 0) {
                        Picker("Feet", selection: $feetSelection) {
                            ForEach(HeightUnit.feetRange, id: \.self) { value in
                                Text("\(value) ft").tag(value)
                            }
                        }
                        .pickerStyle(.wheel)

                        Picker("Inches", selection: $inchesSelection) {
                            ForEach(HeightUnit.inchesRange, id: \.self) { value in
                                Text("\(value) in").tag(value)
                            }
                        }
                        .pickerStyle(.wheel)
                    }
                }
            }
        }
        .onAppear(perform: seed)
        .onChange(of: centimetreSelection) { _, _ in publish() }
        .onChange(of: feetSelection) { _, _ in publish() }
        .onChange(of: inchesSelection) { _, _ in publish() }
        .onChange(of: unit) { _, _ in publish() }
    }

    /// Seeds both wheels from whatever is stored, so switching unit lands on the same height rather
    /// than on the wheel's default.
    private func seed() {
        guard !hasSeeded else { return }
        hasSeeded = true
        if let centimetres {
            centimetreSelection = Int(centimetres.rounded())
            let imperial = HeightUnit.feetAndInches(fromCentimetres: centimetres)
            feetSelection = imperial.feet
            inchesSelection = imperial.inches
        }
        // Publishing on appear is what makes opening the sheet and pressing Done set a height —
        // the wheel is already showing one, so it would be odd for it not to count.
        publish()
    }

    private func publish() {
        switch unit {
        case .centimetres:
            centimetres = Double(centimetreSelection)
        case .feetInches:
            centimetres = HeightUnit.centimetres(fromFeet: feetSelection, inches: inchesSelection)
        }
    }
}

#Preview {
    HeightPickerSheet(centimetres: .constant(180), unit: .constant(.centimetres))
}
