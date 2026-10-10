//
//  JumpSessionRow.swift
//  PerformanceKit
//
//  Created by Findlay Wood on 10/10/2026.
//
import SwiftUI

/// One saved session in the history: its date and how many attempts, then
/// its best height in the chosen unit, with its power beneath for a test that
/// estimates it, inside a card of joined rows.
struct JumpSessionRow: View {

    let session: JumpTestSession
    let measurement: JumpMeasurement
    var showsDivider = false

    private func format(_ centimetres: Double) -> String {
        measurement.display(centimetres: centimetres).formatted(.number.precision(.fractionLength(1)))
    }

    private var subtitle: String {
        let attempts = session.attempts.count == 1 ? "1 attempt" : "\(session.attempts.count) attempts"
        guard let box = session.boxHeight else { return attempts }
        return "\(attempts) · \(Int(box)) cm box"
    }

    var body: some View {
        VStack(spacing: 0) {
            HStack {
                VStack(alignment: .leading, spacing: 2) {
                    Text(session.date, format: .dateTime.day().month(.abbreviated).year())
                        .font(.system(size: 15, weight: .medium))
                        .foregroundStyle(Color.primary)
                    Text(subtitle)
                        .font(.system(size: 12))
                        .foregroundStyle(Color.secondary)
                }
                Spacer()
                if let symmetry = session.symmetry {
                    VStack(alignment: .trailing, spacing: 2) {
                        Text("L \(format(symmetry.left)) · R \(format(symmetry.right)) \(measurement.title)")
                            .font(.system(size: 16, weight: .bold))
                            .foregroundStyle(Color.darkColor)
                        Text(symmetry.summary)
                            .font(.system(size: 12, weight: .medium))
                            .foregroundStyle(symmetry.isNotable ? Color.matteAmber : Color.secondary)
                    }
                } else if let best = session.best {
                    VStack(alignment: .trailing, spacing: 2) {
                        Text(session.kind.headlineText(of: best, measurement: measurement))
                            .font(.system(size: 17, weight: .bold))
                            .foregroundStyle(Color.darkColor)
                        if let detail = session.kind.detail(of: best, measurement: measurement) {
                            Text(detail)
                                .font(.system(size: 12))
                                .foregroundStyle(Color.secondary)
                        }
                        if let power = session.power {
                            Text("\(power.watts.formatted(.number.precision(.fractionLength(0)))) W")
                                .font(.system(size: 12))
                                .foregroundStyle(Color.secondary)
                        }
                    }
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
