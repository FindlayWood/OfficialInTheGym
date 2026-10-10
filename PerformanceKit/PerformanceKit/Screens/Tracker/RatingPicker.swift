//
//  RatingPicker.swift
//  PerformanceKit
//
//  Created by Findlay Wood on 10/10/2026.
//
import SwiftUI

/// A 0–10 rating as a segmented control, "bad" to "great". PerformanceKit's
/// copy of the app's `QuestionView`, which the Wellness tool still uses.
struct RatingPicker: View {

    @Binding var value: Int
    let title: String
    let message: String

    var body: some View {
        VStack {
            Text(message)
            Picker(title, selection: $value) {
                ForEach(0..<11, id: \.self) { number in
                    Text(number, format: .number)
                }
            }
            .pickerStyle(.segmented)
            HStack {
                Text("bad")
                    .font(.footnote)
                    .foregroundColor(.secondary)
                Spacer()
                Text("great")
                    .font(.footnote)
                    .foregroundColor(.secondary)
            }
        }
        .padding(.vertical)
    }
}
