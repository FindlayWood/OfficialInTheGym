//
//  BodyMeasurementRow.swift
//  AccountCreationKit
//
//  Created by Findlay Wood on 09/08/2026.
//

import SwiftUI

/// One optional body measure. Reads "Not set" in tertiary until it has a value, so an untouched row
/// never looks answered.
struct BodyMeasurementRow: View {

    let title: String
    let icon: String
    let value: String?
    var onTap: (() -> Void)?

    var body: some View {
        Button {
            onTap?()
        } label: {
            HStack(spacing: 14) {
                RoundedRectangle(cornerRadius: 10, style: .continuous)
                    .fill(value == nil ? Color(.tertiarySystemFill) : Color.darkColor)
                    .frame(width: 44, height: 44)
                    .overlay(
                        Image(systemName: icon)
                            .font(.system(size: 18, weight: .semibold))
                            .foregroundStyle(value == nil ? Color.secondary : Color.white)
                    )

                Text(title)
                    .font(.system(size: 16, weight: .semibold))
                    .foregroundStyle(Color.primary)

                Spacer(minLength: 0)

                Text(value ?? "Not set")
                    .font(.system(size: 15))
                    .foregroundStyle(value == nil ? Color(.tertiaryLabel) : Color.secondary)

                Image(systemName: "chevron.right")
                    .font(.system(size: 13, weight: .semibold))
                    .foregroundStyle(.tertiary)
            }
            .padding(.horizontal, 16)
            .padding(.vertical, 12)
            .background(
                RoundedRectangle(cornerRadius: 14, style: .continuous)
                    .fill(Color(.secondarySystemBackground))
            )
        }
        .buttonStyle(.plain)
    }
}

#Preview {
    VStack(spacing: 10) {
        BodyMeasurementRow(title: "Height", icon: "ruler", value: "180 cm")
        BodyMeasurementRow(title: "Weight", icon: "scalemass", value: nil)
    }
    .padding()
}
