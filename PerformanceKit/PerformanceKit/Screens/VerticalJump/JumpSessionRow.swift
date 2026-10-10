//
//  JumpSessionRow.swift
//  PerformanceKit
//
//  Created by Findlay Wood on 10/10/2026.
//
import SwiftUI

/// One saved session in the history: its date and how many attempts, then
/// its best height in the chosen unit, inside a card of joined rows.
struct JumpSessionRow: View {

    let session: JumpTestSession
    let measurement: JumpMeasurement
    var showsDivider = false

    var body: some View {
        VStack(spacing: 0) {
            HStack {
                VStack(alignment: .leading, spacing: 2) {
                    Text(session.date, format: .dateTime.day().month(.abbreviated).year())
                        .font(.system(size: 15, weight: .medium))
                        .foregroundStyle(Color.primary)
                    Text(session.attempts.count == 1 ? "1 attempt" : "\(session.attempts.count) attempts")
                        .font(.system(size: 12))
                        .foregroundStyle(Color.secondary)
                }
                Spacer()
                if let best = session.best {
                    Text("\(measurement.display(centimetres: best.height), specifier: "%.1f") \(measurement.title)")
                        .font(.system(size: 17, weight: .bold))
                        .foregroundStyle(Color.darkColor)
                }
            }
            .padding(.horizontal, 16)
            .frame(minHeight: 56)
            if showsDivider {
                Divider().padding(.leading, 16)
            }
        }
    }
}
