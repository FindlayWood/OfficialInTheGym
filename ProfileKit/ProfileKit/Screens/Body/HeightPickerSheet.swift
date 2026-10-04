//
//  HeightPickerSheet.swift
//  ProfileKit
//
//  Created by Findlay Wood on 03/10/2026.
//
import SwiftUI

/// ProfileKit's copy of AccountCreationKit's `HeightPickerSheet`, **kept in
/// step with it**: wheels, a unit switch that converts rather than clears, and
/// a value published on appear, so opening the sheet and pressing Done keeps
/// the height the wheel shows.
struct HeightPickerSheet: View {

    @Binding var centimetres: Double?
    @Binding var unit: ProfileHeightUnit

    @Environment(\.dismiss) private var dismiss

    @State private var centimetreSelection: Int = 175
    @State private var feetSelection: Int = 5
    @State private var inchesSelection: Int = 9
    @State private var hasSeeded = false

    var body: some View {
        ProfilePickerSheet(
            title: "Height",
            hasValue: centimetres != nil,
            onClear: {
                centimetres = nil
                dismiss()
            },
            onAction: { dismiss() }
        ) {
            VStack(spacing: 12) {
                Picker("Unit", selection: $unit) {
                    ForEach(ProfileHeightUnit.allCases) { option in
                        Text(option.label).tag(option)
                    }
                }
                .pickerStyle(.segmented)
                .padding(.horizontal, 20)

                switch unit {
                case .centimetres:
                    Picker("Centimetres", selection: $centimetreSelection) {
                        ForEach(ProfileHeightUnit.minimumCentimetres...ProfileHeightUnit.maximumCentimetres, id: \.self) { value in
                            Text("\(value) cm").tag(value)
                        }
                    }
                    .pickerStyle(.wheel)

                case .feetInches:
                    HStack(spacing: 0) {
                        Picker("Feet", selection: $feetSelection) {
                            ForEach(ProfileHeightUnit.feetRange, id: \.self) { value in
                                Text("\(value) ft").tag(value)
                            }
                        }
                        .pickerStyle(.wheel)

                        Picker("Inches", selection: $inchesSelection) {
                            ForEach(ProfileHeightUnit.inchesRange, id: \.self) { value in
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

    private func seed() {
        guard !hasSeeded else { return }
        hasSeeded = true
        if let centimetres {
            centimetreSelection = Int(centimetres.rounded())
            let imperial = ProfileHeightUnit.feetAndInches(fromCentimetres: centimetres)
            feetSelection = imperial.feet
            inchesSelection = imperial.inches
        }
        publish()
    }

    private func publish() {
        switch unit {
        case .centimetres:
            centimetres = Double(centimetreSelection)
        case .feetInches:
            centimetres = ProfileHeightUnit.centimetres(fromFeet: feetSelection, inches: inchesSelection)
        }
    }
}
