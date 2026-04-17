//
//  RPECard.swift
//  MyDayKit
//
//  Created by Findlay Wood on 17/04/2026.
//

import SwiftUI

// MARK: - RPECard
// Shows a prompt to log RPE after exercises have been tracked.
// Expands inline to show the score picker, collapses to a summary once logged.
struct RPECard: View {
    var entry: RPEEntry?
    var isCurrentDay: Bool
    var onConfirm: ((Int) -> ())?

    @State private var isExpanded: Bool = false
    @State private var pendingScore: Int? = nil

    var body: some View {
        VStack(spacing: 0) {
            if let entry {
                completedView(entry: entry)
            } else if isCurrentDay {
                if isExpanded {
                    expandedView
                } else {
                    promptView
                }
            } else {
                pastDayView
            }
        }
        .background(Color(.systemBackground))
        .clipShape(RoundedRectangle(cornerRadius: 16))
        .overlay(
            RoundedRectangle(cornerRadius: 16)
                .stroke(borderColor, lineWidth: borderWidth)
        )
        .animation(.spring(response: 0.4, dampingFraction: 0.85), value: isExpanded)
        .animation(.spring(response: 0.4, dampingFraction: 0.85), value: pendingScore)
    }

    // MARK: - Prompt (collapsed)
    private var promptView: some View {
        Button(action: {
            withAnimation { isExpanded = true }
        }) {
            HStack(spacing: 14) {
                ZStack {
                    RoundedRectangle(cornerRadius: 10)
                        .fill(Color.purple.opacity(0.12))
                        .frame(width: 50, height: 50)
                    Image(systemName: "dial.medium.fill")
                        .font(.system(size: 22))
                        .foregroundStyle(.purple)
                }

                VStack(alignment: .leading, spacing: 3) {
                    Text("Session Intensity")
                        .font(.subheadline).fontWeight(.semibold)
                    Text("How hard was today's training?")
                        .font(.caption)
                        .foregroundStyle(.secondary)
                }

                Spacer()

                Text("Log RPE")
                    .font(.caption).fontWeight(.semibold)
                    .padding(.horizontal, 12)
                    .padding(.vertical, 6)
                    .background(Color.purple)
                    .foregroundStyle(.white)
                    .clipShape(Capsule())
            }
            .padding(16)
        }
        .buttonStyle(.plain)
    }

    // MARK: - Expanded picker
    private var expandedView: some View {
        VStack(spacing: 16) {
            // Header
            HStack(spacing: 14) {
                ZStack {
                    RoundedRectangle(cornerRadius: 10)
                        .fill(Color.purple.opacity(0.12))
                        .frame(width: 50, height: 50)
                    Image(systemName: "dial.medium.fill")
                        .font(.system(size: 22))
                        .foregroundStyle(.purple)
                }

                VStack(alignment: .leading, spacing: 3) {
                    Text("Session Intensity")
                        .font(.subheadline).fontWeight(.semibold)
                    Text("How hard was today's training?")
                        .font(.caption)
                        .foregroundStyle(.secondary)
                }

                Spacer()

                Button(action: {
                    withAnimation { isExpanded = false }
                }) {
                    Image(systemName: "xmark")
                        .font(.caption)
                        .foregroundStyle(.secondary)
                        .padding(8)
                        .background(Color(.secondarySystemFill))
                        .clipShape(Circle())
                }
            }

            // Anchor labels
            HStack {
                Text("1 · Very light")
                    .font(.caption2)
                    .foregroundStyle(.secondary)
                Spacer()
                Text("10 · Maximum effort")
                    .font(.caption2)
                    .foregroundStyle(.secondary)
            }
            .padding(.horizontal, 2)

            // Score buttons
            HStack(spacing: 5) {
                ForEach(1...10, id: \.self) { score in
                    Button(action: {
                        withAnimation(.easeInOut(duration: 0.15)) {
                            pendingScore = score
                        }
                    }) {
                        ZStack {
                            RoundedRectangle(cornerRadius: 8)
                                .fill(pendingScore == score
                                      ? rpeColor(score)
                                      : Color(.secondarySystemFill))
                            Text("\(score)")
                                .font(.system(size: 14, weight: .semibold, design: .rounded))
                                .foregroundStyle(pendingScore == score ? .white : .primary)
                        }
                        .frame(height: 44)
                        .frame(maxWidth: .infinity)
                    }
                    .buttonStyle(.plain)
                }
            }

            // Selected label
            if let score = pendingScore {
                HStack(spacing: 6) {
                    Circle()
                        .fill(rpeColor(score))
                        .frame(width: 8, height: 8)
                    Text(rpeLabel(score))
                        .font(.subheadline).fontWeight(.medium)
                        .foregroundStyle(rpeColor(score))
                }
                .frame(maxWidth: .infinity, alignment: .center)
                .transition(.opacity.combined(with: .scale(scale: 0.9)))
            }

            // Confirm button
            Button(action: {
                guard let score = pendingScore else { return }
                withAnimation {
                    isExpanded = false
                    onConfirm?(score)
                }
            }) {
                Text("Confirm")
                    .font(.system(size: 15, weight: .semibold))
                    .foregroundStyle(.white)
                    .frame(maxWidth: .infinity)
                    .padding(.vertical, 13)
                    .background(pendingScore != nil ? Color.purple : Color.gray.opacity(0.4))
                    .clipShape(RoundedRectangle(cornerRadius: 12))
            }
            .disabled(pendingScore == nil)
        }
        .padding(16)
    }

    // MARK: - Completed
    private func completedView(entry: RPEEntry) -> some View {
        HStack(spacing: 14) {
            ZStack {
                RoundedRectangle(cornerRadius: 10)
                    .fill(rpeColor(entry.score).opacity(0.12))
                    .frame(width: 50, height: 50)
                Text("\(entry.score)")
                    .font(.system(size: 20, weight: .bold, design: .rounded))
                    .foregroundStyle(rpeColor(entry.score))
            }

            VStack(alignment: .leading, spacing: 3) {
                Text(entry.label)
                    .font(.subheadline).fontWeight(.semibold)
                    .foregroundStyle(rpeColor(entry.score))
                Text("Session intensity logged")
                    .font(.caption)
                    .foregroundStyle(.secondary)
            }

            Spacer()

            // Mini intensity bar
            HStack(spacing: 2) {
                ForEach(1...10, id: \.self) { pip in
                    RoundedRectangle(cornerRadius: 2)
                        .fill(pip <= entry.score ? rpeColor(entry.score) : Color(.tertiarySystemFill))
                        .frame(width: 6, height: pip <= entry.score ? 16 : 10)
                }
            }
            .frame(alignment: .bottom)
        }
        .padding(16)
    }

    // MARK: - Past day, no entry
    private var pastDayView: some View {
        HStack(spacing: 14) {
            ZStack {
                RoundedRectangle(cornerRadius: 10)
                    .fill(Color.secondary.opacity(0.08))
                    .frame(width: 50, height: 50)
                Image(systemName: "dial.medium")
                    .font(.system(size: 22))
                    .foregroundStyle(.secondary)
            }

            VStack(alignment: .leading, spacing: 3) {
                Text("No RPE Logged")
                    .font(.subheadline).fontWeight(.semibold)
                Text("Session intensity was not recorded.")
                    .font(.caption)
                    .foregroundStyle(.secondary)
            }

            Spacer()
        }
        .padding(16)
    }

    // MARK: - Helpers
    private var borderColor: Color {
        if isExpanded { return .purple.opacity(0.4) }
        if entry != nil { return Color(.separator).opacity(0.4) }
        return isCurrentDay ? .purple.opacity(0.25) : Color(.separator).opacity(0.4)
    }

    private var borderWidth: CGFloat {
        isExpanded ? 1.5 : 0.5
    }

    private func rpeColor(_ score: Int) -> Color {
        switch score {
        case 1...3:  return .blue
        case 4...6:  return .green
        case 7...8:  return .orange
        case 9...10: return .red
        default:     return .gray
        }
    }

    private func rpeLabel(_ score: Int) -> String {
        switch score {
        case 1...2:  return "Very Light"
        case 3...4:  return "Light"
        case 5...6:  return "Moderate"
        case 7...8:  return "Hard"
        case 9:      return "Very Hard"
        case 10:     return "Maximum"
        default:     return ""
        }
    }
}

// MARK: - Preview
#Preview {
    ScrollView {
        VStack(spacing: 12) {
            // Today, not yet logged
            RPECard(entry: nil, isCurrentDay: true, onConfirm: { _ in })

            // Today, logged
            RPECard(entry: RPEEntry(score: 7), isCurrentDay: true, onConfirm: { _ in })

            // Past day, not logged
            RPECard(entry: nil, isCurrentDay: false, onConfirm: { _ in })

            // Past day, logged
            RPECard(entry: RPEEntry(score: 3), isCurrentDay: false, onConfirm: { _ in })
        }
        .padding()
    }
    .background(Color(.systemGroupedBackground))
}
