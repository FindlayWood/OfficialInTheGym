//
//  WeightHistoryRow.swift
//  ProfileKit
//
//  Created by Findlay Wood on 03/10/2026.
//
import SwiftUI

/// One logged day: the date, then the weight in the screen's unit. Deleting is
/// behind a long-press menu, as an entry in a log is not something to lose to
/// a stray tap.
struct WeightHistoryRow: View {

    let entry: WeightEntry
    let unit: ProfileWeightUnit
    var showsDivider = true
    let onDelete: () -> Void

    var body: some View {
        VStack(spacing: 0) {
            HStack {
                Text(WeightDay.displayFormatter.string(from: entry.date))
                    .font(.system(size: 15, weight: .medium))
                    .foregroundStyle(Color.primary)
                Spacer()
                Text(unit.display(kilograms: entry.weightKilograms))
                    .font(.system(size: 15, weight: .semibold).monospacedDigit())
                    .foregroundStyle(Color.primary)
            }
            .padding(.horizontal, 16)
            .frame(minHeight: 48)
            .contentShape(Rectangle())
            .contextMenu {
                Button("Delete Entry", systemImage: "trash", role: .destructive, action: onDelete)
            }
            if showsDivider {
                Divider().padding(.leading, 16)
            }
        }
    }
}
