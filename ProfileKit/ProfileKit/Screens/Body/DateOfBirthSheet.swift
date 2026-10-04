//
//  DateOfBirthSheet.swift
//  ProfileKit
//
//  Created by Findlay Wood on 03/10/2026.
//
import SwiftUI

/// ProfileKit's copy of AccountCreationKit's `DateOfBirthSheet`, **kept in
/// step with it**, including the 13-year floor. As at signup, that floor is the
/// wheel refusing to express a younger date, **not an age gate**.
struct DateOfBirthSheet: View {

    @Binding var dateOfBirth: Date?

    @Environment(\.dismiss) private var dismiss

    @State private var selection: Date = DateOfBirthSheet.defaultSelection
    @State private var hasSeeded = false

    private static let minimumAge: Int = 13
    private static let maximumAge: Int = 100

    private static var defaultSelection: Date {
        Calendar.current.date(byAdding: .year, value: -25, to: .now) ?? .now
    }

    private var range: ClosedRange<Date> {
        let calendar = Calendar.current
        let newest = calendar.date(byAdding: .year, value: -Self.minimumAge, to: .now) ?? .now
        let oldest = calendar.date(byAdding: .year, value: -Self.maximumAge, to: .now) ?? .now
        return oldest...newest
    }

    var body: some View {
        ProfilePickerSheet(
            title: "Date of Birth",
            hasValue: dateOfBirth != nil,
            onClear: {
                dateOfBirth = nil
                dismiss()
            },
            onAction: { dismiss() }
        ) {
            DatePicker("Date of Birth", selection: $selection, in: range, displayedComponents: .date)
                .datePickerStyle(.wheel)
                .labelsHidden()
        }
        .onAppear(perform: seed)
        .onChange(of: selection) { _, newValue in dateOfBirth = newValue }
    }

    private func seed() {
        guard !hasSeeded else { return }
        hasSeeded = true
        if let dateOfBirth {
            selection = dateOfBirth
        }
        dateOfBirth = selection
    }
}
