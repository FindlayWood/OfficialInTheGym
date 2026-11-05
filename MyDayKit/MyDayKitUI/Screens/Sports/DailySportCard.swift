//
//  DailySportCard.swift
//  MyDayKit
//
//  Created by Findlay Wood on 05/11/2026.
//

import SwiftUI

/// A sport session on the day's train step. **Built on `DailyWorkoutCard`'s chrome** — the
/// same uppercase label, 16 semibold title, 13pt subtitle with a trailing chip, and the `⋯`
/// above the card — so a game and a workout on one day read as the same kind of thing.
///
/// The card is not tappable: a session has nothing more to show than the card says. The `⋯`
/// is offered only while the day can be edited (`onRemove` set), and holds the one action.
struct DailySportCard: View {

    let session: SportSessionEntry
    var onRemove: (() -> Void)?

    @State private var showOptions = false

    private var summary: SportSessionSummary { SportSessionSummary(session) }

    var body: some View {
        ZStack(alignment: .topTrailing) {
            cardContent

            if onRemove != nil {
                Button { showOptions = true } label: {
                    ZStack {
                        Circle()
                            .fill(Color(UIColor.tertiarySystemGroupedBackground))
                            .frame(width: 32, height: 32)
                        Image(systemName: "ellipsis")
                            .font(.system(size: 13, weight: .medium))
                            .foregroundColor(.secondary)
                    }
                    .frame(width: 50, height: 50)
                }
                .buttonStyle(.plain)
                .padding(8)
            }
        }
        .sheet(isPresented: $showOptions) {
            SportCardOptionsSheet(
                title: summary.title,
                onRemove: {
                    showOptions = false
                    onRemove?()
                }
            )
            .presentationDetents([.height(150)])
            .presentationDragIndicator(.visible)
        }
    }

    private var cardContent: some View {
        VStack(alignment: .leading, spacing: 8) {
            Text(summary.label)
                .font(.system(size: 10, weight: .semibold))
                .foregroundColor(.secondary)
                .tracking(1.5)

            HStack(spacing: 8) {
                Image(systemName: session.sport.icon)
                    .font(.system(size: 14, weight: .semibold))
                    .foregroundColor(Color.darkColor)
                Text(summary.title)
                    .font(.system(size: 16, weight: .semibold))
                    .foregroundColor(.primary)
                    .lineLimit(1)
            }

            HStack {
                Text(summary.subtitle)
                    .font(.system(size: 13))
                    .foregroundColor(.secondary)
                Spacer()
                if let outcome = summary.outcome {
                    Text(outcome)
                        .font(.system(size: 11, weight: .semibold))
                        .foregroundColor(outcomeColor)
                }
            }
        }
        .padding(16)
        .frame(maxWidth: .infinity, alignment: .leading)
        .background(Color(UIColor.secondarySystemGroupedBackground))
        .clipShape(RoundedRectangle(cornerRadius: 16))
        .shadow(color: Color.black.opacity(0.06), radius: 8, x: 0, y: 2)
    }

    /// The result's own colour; a score with no result is just a fact, so it stays secondary.
    private var outcomeColor: Color {
        session.result?.color ?? .secondary
    }
}

#Preview {
    VStack(spacing: 12) {
        DailySportCard(
            session: SportSessionEntry(
                id: "1", sport: .basketball, sessionType: .game, performedAt: .now,
                duration: 5_400, playingTime: 2_400, rpe: 7, result: .win,
                teamScore: 68, opponentScore: 61, note: nil
            ),
            onRemove: {}
        )
        DailySportCard(
            session: SportSessionEntry(
                id: "2", sport: .golf, sessionType: .training, performedAt: .now,
                duration: 14_400, playingTime: nil, rpe: 3, result: nil,
                teamScore: nil, opponentScore: nil, note: nil
            )
        )
    }
    .padding()
    .background(Color(UIColor.systemGroupedBackground))
}
