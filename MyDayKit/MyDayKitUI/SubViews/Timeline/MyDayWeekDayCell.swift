//
//  MyDayWeekDayCell.swift
//  MyDayKit
//
//  Created by Findlay Wood on 18/10/2026.
//

import SwiftUI

/// One day in `MyDayWeekCard`: weekday initial, date, and the same three marker dots the date
/// strip draws, so a day reads identically in both places. The day being viewed is outlined;
/// a day the strip cannot reach (in the future, or before its window) is dimmed and inert.
struct MyDayWeekDayCell: View {
    let date: Date
    let markers: MyDayDayMarkers
    let isCurrent: Bool
    let isReachable: Bool
    var isSignupDay: Bool = false
    let onTap: () -> Void

    var body: some View {
        Button(action: onTap) {
            VStack(spacing: 3) {
                Text(date, format: .dateTime.weekday(.narrow))
                    .font(.system(size: 10, weight: .medium))
                    .foregroundStyle(Color.secondary)
                Text(date, format: .dateTime.day())
                    .font(.system(size: 14, weight: .semibold))
                    .foregroundStyle(Color.primary)
                MyDayDayMarkerDots(markers: markers, isSelected: false)
            }
            .frame(maxWidth: .infinity)
            .padding(.vertical, 7)
            .background(Color(UIColor.tertiarySystemGroupedBackground))
            .clipShape(RoundedRectangle(cornerRadius: 10))
            .overlay {
                RoundedRectangle(cornerRadius: 10)
                    .strokeBorder(isCurrent ? Color.darkColor : Color.clear, lineWidth: 1.5)
            }
            .overlay(alignment: .topTrailing) {
                if isSignupDay {
                    MyDaySignupBadge(size: 12)
                        .padding(3)
                }
            }
        }
        .buttonStyle(.plain)
        .disabled(!isReachable || isCurrent)
        .opacity(isReachable ? 1 : 0.35)
    }
}
