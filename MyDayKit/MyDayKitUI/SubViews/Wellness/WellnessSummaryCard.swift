//
//  WellnessSummaryCard.swift
//  MyDayKit
//
//  Created by Findlay Wood on 16/04/2026.
//

import SwiftUI

// MARK: - WellnessSummaryCard
// Drop this at the top of MyDay. Shows prompt if not completed, summary if done.
struct WellnessSummaryCard: View {
    var entry: WellnessEntry?
    var isCurrentDay: Bool = false
    var onTap: (() -> ())?

    public var body: some View {
        Button {
            guard entry == nil else { return }
            onTap?()
        } label: {
            if let entry {
                completedView(entry: entry)
            } else if isCurrentDay {
                promptView
            } else {
                pastDayView
            }
        }
        .buttonStyle(.plain)
        .disabled(!isCurrentDay)
    }
    
    // MARK: Not completed, past day
    private var pastDayView: some View {
        HStack(spacing: 14) {
            ZStack {
                RoundedRectangle(cornerRadius: 10)
                    .fill(Color.secondary.opacity(0.08))
                    .frame(width: 50, height: 50)
                Image(systemName: "moon.zzz.fill")
                    .font(.system(size: 22))
                    .foregroundStyle(.secondary)
            }

            VStack(alignment: .leading, spacing: 3) {
                Text("No Check-in")
                    .font(.subheadline).fontWeight(.semibold)
                    .foregroundStyle(.primary)
                Text("No wellness data was recorded for this day.")
                    .font(.caption)
                    .foregroundStyle(.secondary)
                    .lineLimit(2)
            }

            Spacer()
        }
        .padding(16)
        .background(Color(UIColor.secondarySystemBackground))
        .clipShape(RoundedRectangle(cornerRadius: 16))
        .overlay(
            RoundedRectangle(cornerRadius: 16)
                .stroke(Color.black.opacity(0.4), lineWidth: 0.5)
        )
        .shadow(color: Color.black.opacity(0.06), radius: 8, x: 0, y: 2)
    }

    // MARK: Not yet completed
    private var promptView: some View {
        HStack(spacing: 14) {
            ZStack {
                RoundedRectangle(cornerRadius: 10)
                    .fill(Color.orange.opacity(0.12))
                    .frame(width: 50, height: 50)
                Image(systemName: "sun.max.fill")
                    .font(.system(size: 22))
                    .foregroundStyle(.orange)
            }

            VStack(alignment: .leading, spacing: 3) {
                Text("Daily Check-in")
                    .font(.subheadline).fontWeight(.semibold)
                Text("How are you feeling today?")
                    .font(.caption)
                    .foregroundStyle(.secondary)
            }

            Spacer()

            Text("Start")
                .font(.caption).fontWeight(.semibold)
                .padding(.horizontal, 12)
                .padding(.vertical, 6)
                .background(Color.orange)
                .foregroundStyle(.white)
                .clipShape(Capsule())
        }
        .padding(16)
        .background(Color(UIColor.secondarySystemBackground))
        .clipShape(RoundedRectangle(cornerRadius: 16))
        .overlay(
            RoundedRectangle(cornerRadius: 16)
                .stroke(Color.orange.opacity(0.3), lineWidth: 1)
        )
        .shadow(color: Color.black.opacity(0.06), radius: 8, x: 0, y: 2)
    }

    // MARK: Completed
    private func completedView(entry: WellnessEntry) -> some View {
        HStack(spacing: 14) {
            ZStack {
                RoundedRectangle(cornerRadius: 10)
                    .fill(readinessColor(entry).opacity(0.12))
                    .frame(width: 50, height: 50)
                Image(systemName: "checkmark.circle.fill")
                    .font(.system(size: 22))
                    .foregroundStyle(readinessColor(entry))
            }

            VStack(alignment: .leading, spacing: 3) {
                Text(entry.readinessLevel.label)
                    .font(.subheadline).fontWeight(.semibold)
                Text(entry.readinessLevel.suggestion)
                    .font(.caption)
                    .foregroundStyle(.secondary)
                    .lineLimit(2)
            }

            Spacer()

            // Mini score dots
            HStack(spacing: 4) {
                ForEach([
                    entry.sleepQuality,
                    entry.physicalReadiness,
                    entry.mentalEnergy,
                    entry.overallMood
                ], id: \.rawValue) { score in
                    Circle()
                        .fill(scoreColor(score))
                        .frame(width: 8, height: 8)
                }
            }
        }
        .padding(16)
        .background(Color(UIColor.secondarySystemBackground))
        .clipShape(RoundedRectangle(cornerRadius: 16))
        .overlay(
            RoundedRectangle(cornerRadius: 16)
                .stroke(Color.black.opacity(0.4), lineWidth: 0.5)
        )
        .shadow(color: Color.black.opacity(0.06), radius: 8, x: 0, y: 2)
    }

    private func readinessColor(_ entry: WellnessEntry) -> Color {
        switch entry.readinessLevel {
        case .low:       return .red
        case .moderate:  return .orange
        case .good:      return .blue
        case .excellent: return .green
        }
    }

    private func scoreColor(_ score: WellnessScore) -> Color {
        switch score {
        case .one:   return .red
        case .two:   return .orange
        case .three: return .yellow
        case .four:  return .blue
        case .five:  return .green
        }
    }
}

#Preview {
    WellnessSummaryCard()
}
