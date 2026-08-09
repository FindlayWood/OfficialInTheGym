//
//  DateOfBirthSheet.swift
//  AccountCreationKit
//
//  Created by Findlay Wood on 09/08/2026.
//

import SwiftUI

/// Date of birth rather than an age in years, so it does not go stale the moment it is entered and
/// there is never a second conversation about correcting it.
struct DateOfBirthSheet: View {

    @Binding var dateOfBirth: Date?

    @Environment(\.dismiss) private var dismiss

    @State private var selection: Date = DateOfBirthSheet.defaultSelection
    @State private var hasSeeded = false

    /// 13 is the floor because an account is being created here, and a younger date of birth is a
    /// question about consent rather than a number to store. **Not a substitute for a real age gate**
    /// — the picker simply cannot express it.
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
        AccountCreationPickerSheet(
            title: "Date of Birth",
            hasValue: dateOfBirth != nil,
            onClear: {
                dateOfBirth = nil
                dismiss()
            },
            onDone: { dismiss() }
        ) {
            DatePicker(
                "Date of Birth",
                selection: $selection,
                in: range,
                displayedComponents: .date
            )
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

#Preview {
    DateOfBirthSheet(dateOfBirth: .constant(nil))
}
