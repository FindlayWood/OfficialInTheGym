//
//  DiscoverRatingSheet.swift
//  DiscoverKit
//
//  Created by Findlay Wood on 30/09/2026.
//

import SwiftUI

/// A 1–10 picker in the shape of MyDay's `WorkoutExerciseRPESheet` — a 5×2
/// grid of 52pt cells, flash-then-dismiss — so rating and RPE feel like the
/// same control.
///
/// **Not RPE's green-to-red scale.** Those colours mean effort; on a rating
/// they would read as a verdict on each number, and a selection is an accent,
/// which is `darkColor` everywhere in the app.
struct DiscoverRatingSheet: View {

    let currentRating: Int?
    var onSelect: (Int) -> Void

    @State private var flashingValue: Int?

    private let columns = Array(repeating: GridItem(.flexible(), spacing: 8), count: 5)

    var body: some View {
        VStack(alignment: .leading, spacing: 0) {
            VStack(alignment: .leading, spacing: 3) {
                Text("Your rating")
                    .font(.system(size: 16, weight: .semibold))
                    .foregroundStyle(Color.primary)
                Text("1 is poor, 10 is excellent")
                    .font(.system(size: 13))
                    .foregroundStyle(Color.secondary)
            }
            .padding(.horizontal, 20)
            .padding(.top, 20)
            .padding(.bottom, 16)

            Divider()

            LazyVGrid(columns: columns, spacing: 8) {
                ForEach(1...10, id: \.self) { value in
                    let highlighted = flashingValue == value || (currentRating == value && flashingValue == nil)
                    Button {
                        guard flashingValue == nil else { return }
                        flashingValue = value
                        Task {
                            try? await Task.sleep(nanoseconds: 300_000_000)
                            onSelect(value)
                        }
                    } label: {
                        Text("\(value)")
                            .font(.system(size: 17, weight: .bold))
                            .foregroundStyle(highlighted ? .white : Color.darkColor)
                            .frame(maxWidth: .infinity)
                            .frame(height: 52)
                            .background(
                                RoundedRectangle(cornerRadius: 14)
                                    .fill(highlighted ? Color.darkColor : Color(UIColor.secondarySystemBackground))
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
}

#Preview {
    DiscoverRatingSheet(currentRating: 7) { _ in }
        .presentationDetents([.height(260)])
}
