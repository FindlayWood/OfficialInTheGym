//
//  TrackedSessionRow.swift
//  PerformanceKit
//
//  Created by Findlay Wood on 10/10/2026.
//
import SwiftUI

/// A recorded session: the overall rating in a `darkColor` tile where other
/// rows carry an icon, the date, and the four ratings on one line, as a card.
struct TrackedSessionRow: View {

    let session: TrackedSession

    var body: some View {
        HStack(spacing: 14) {
            RoundedRectangle(cornerRadius: 10, style: .continuous)
                .fill(Color.darkColor)
                .frame(width: 44, height: 44)
                .overlay(
                    Text("\(session.ratings.overall)")
                        .font(.system(size: 20, weight: .bold))
                        .foregroundStyle(Color.white)
                )
            VStack(alignment: .leading, spacing: 3) {
                Text(session.date, format: .dateTime.weekday(.abbreviated).day().month(.abbreviated).year())
                    .font(.system(size: 16, weight: .semibold))
                    .foregroundStyle(Color.primary)
                Text(summary)
                    .font(.system(size: 13))
                    .foregroundStyle(Color.secondary)
                    .lineLimit(1)
                    .minimumScaleFactor(0.85)
            }
            Spacer(minLength: 8)
            Image(systemName: "chevron.right")
                .font(.system(size: 13, weight: .semibold))
                .foregroundStyle(Color(.tertiaryLabel))
        }
        .padding(.horizontal, 16)
        .padding(.vertical, 12)
        .performanceCard()
    }

    private var summary: String {
        let r = session.ratings
        return "Tech \(r.technical) · Tact \(r.tactical) · Phys \(r.physical) · Ment \(r.mental)"
    }
}
