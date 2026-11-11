//
//  InjuryPainScale.swift
//  MyDayKit
//
//  Created by Findlay Wood on 10/11/2026.
//

import SwiftUI

/// Pain from 0 to 10, one cell per step, with "None" and "Worst" under the ends so the scale
/// reads without a legend.
///
/// **The matte set marks how bad, not the brand.** A pain of 8 drawn in the accent would read
/// as "selected", not as "bad"; green / amber / red say what the number means, at the same
/// lightness so no step shouts. The boundaries live in `color(for:)` only.
struct InjuryPainScale: View {

    let selected: Int?
    let onSelect: (Int) -> Void

    var body: some View {
        VStack(spacing: 6) {
            HStack(spacing: 4) {
                ForEach(Array(InjuryCheckIn.painRange), id: \.self) { value in
                    let isSelected = value == selected
                    Button {
                        onSelect(value)
                    } label: {
                        Text("\(value)")
                            .font(.system(size: 13, weight: .semibold))
                            .frame(maxWidth: .infinity)
                            .frame(height: 36)
                            .background(
                                RoundedRectangle(cornerRadius: 8, style: .continuous)
                                    .fill(isSelected ? Self.color(for: value) : Color(.tertiarySystemGroupedBackground))
                            )
                            .foregroundStyle(isSelected ? Color.white : Color.secondary)
                    }
                    .buttonStyle(.plain)
                    .accessibilityLabel("Pain \(value) of 10")
                    .accessibilityAddTraits(isSelected ? .isSelected : [])
                }
            }
            HStack {
                Text("None")
                Spacer()
                Text("Worst")
            }
            .font(.system(size: 11, weight: .medium))
            .foregroundStyle(Color.secondary)
        }
        .animation(.easeInOut(duration: 0.15), value: selected)
    }

    static func color(for pain: Int) -> Color {
        switch pain {
        case ..<4: return .matteGreen
        case 4..<7: return .matteAmber
        default: return .matteRed
        }
    }
}
