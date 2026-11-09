//
//  ScheduledSportCard.swift
//  MyDayKit
//
//  Created by Findlay Wood on 09/11/2026.
//

import SwiftUI

/// A sport due today, logged on the card. The time is already filled in, so most days this is one
/// tap on the RPE scale and one on Done. **Built on `DailySportCard`'s chrome**, so it reads as the
/// card it will become.
///
/// **Done needs an RPE.** A session without one adds nothing to STATS, so saving it would look logged
/// and count for nothing. The normal sport flow leaves RPE optional; this is the one place it does
/// not, because the card exists to make the common case complete.
///
/// **Changing the time here changes today only.** The schedule keeps its usual time.
struct ScheduledSportCard: View {

    let item: ScheduledSport
    let onDone: (_ duration: Int, _ rpe: Int) -> Void
    let onNotToday: () -> Void

    @State private var duration: Int
    @State private var rpe: Int?
    @State private var showingTimePicker = false

    init(
        item: ScheduledSport,
        onDone: @escaping (_ duration: Int, _ rpe: Int) -> Void,
        onNotToday: @escaping () -> Void
    ) {
        self.item = item
        self.onDone = onDone
        self.onNotToday = onNotToday
        _duration = State(initialValue: item.duration)
    }

    private var canFinish: Bool {
        rpe != nil && duration > 0
    }

    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            header
            timeRow
            rpeRow
            actions
        }
        .padding(16)
        .frame(maxWidth: .infinity, alignment: .leading)
        .background(Color(UIColor.secondarySystemGroupedBackground))
        .clipShape(RoundedRectangle(cornerRadius: 16))
        .shadow(color: Color.black.opacity(0.06), radius: 8, x: 0, y: 2)
        .sheet(isPresented: $showingTimePicker) {
            SportTimeSelectorView(
                title: "Session Duration",
                subtitle: "How long was your session?",
                currentValue: duration
            ) { value in
                duration = value
            }
            .presentationDetents([.medium, .large])
        }
    }

    // MARK: - Header

    private var header: some View {
        VStack(alignment: .leading, spacing: 8) {
            Text("TRAINING")
                .font(.system(size: 10, weight: .semibold))
                .foregroundColor(.secondary)
                .tracking(1.5)

            HStack(spacing: 8) {
                Image(systemName: item.sport.icon)
                    .font(.system(size: 14, weight: .semibold))
                    .foregroundColor(Color.darkColor)
                Text(item.sport.rawValue)
                    .font(.system(size: 16, weight: .semibold))
                    .foregroundColor(.primary)
                    .lineLimit(1)
                Spacer()
                HStack(spacing: 4) {
                    Image(systemName: "calendar")
                        .font(.system(size: 10, weight: .bold))
                    Text("Scheduled")
                        .font(.system(size: 11, weight: .semibold))
                }
                .foregroundColor(Color.darkColor)
            }
        }
    }

    // MARK: - Time

    private var timeRow: some View {
        Button {
            showingTimePicker = true
        } label: {
            HStack {
                Text("Time")
                    .font(.system(size: 14, weight: .medium))
                    .foregroundStyle(Color.primary)
                Spacer()
                Text(SportSessionSummary.formatted(seconds: duration))
                    .font(.system(size: 14, weight: .semibold))
                    .foregroundStyle(Color.darkColor)
                Image(systemName: "chevron.right")
                    .font(.system(size: 12, weight: .semibold))
                    .foregroundStyle(Color(UIColor.tertiaryLabel))
            }
            .padding(.horizontal, 12)
            .frame(height: 44)
            .background(Color(UIColor.tertiarySystemGroupedBackground))
            .clipShape(RoundedRectangle(cornerRadius: 12))
        }
        .buttonStyle(.plain)
    }

    // MARK: - RPE

    private var rpeRow: some View {
        VStack(alignment: .leading, spacing: 6) {
            HStack {
                Text("Effort (RPE)")
                    .font(.system(size: 14, weight: .medium))
                    .foregroundStyle(Color.primary)
                Spacer()
                if let rpe {
                    Text("\(rpe)/10")
                        .font(.system(size: 14, weight: .bold))
                        .foregroundStyle(RPEScale.color(for: rpe))
                }
            }

            HStack(spacing: 4) {
                ForEach(1...10, id: \.self) { value in
                    Button {
                        withAnimation(.easeInOut(duration: 0.15)) {
                            rpe = value
                        }
                    } label: {
                        RoundedRectangle(cornerRadius: 4)
                            .fill(value <= (rpe ?? 0) ? RPEScale.color(for: value) : Color(UIColor.tertiarySystemGroupedBackground))
                            .frame(height: 36)
                            .overlay {
                                Text("\(value)")
                                    .font(.system(size: 11, weight: .semibold))
                                    .foregroundStyle(value <= (rpe ?? 0) ? Color.white : Color.secondary)
                            }
                    }
                    .buttonStyle(.plain)
                    .accessibilityLabel("Effort \(value) of 10")
                    .accessibilityAddTraits(rpe == value ? .isSelected : [])
                }
            }
        }
    }

    // MARK: - Actions

    private var actions: some View {
        HStack(spacing: 12) {
            Button {
                if let rpe { onDone(duration, rpe) }
            } label: {
                Text("Done")
                    .font(.system(size: 16, weight: .semibold))
                    .foregroundStyle(canFinish ? Color.white : Color.secondary)
                    .frame(maxWidth: .infinity)
                    .frame(height: 44)
                    .background(canFinish ? Color.darkColor : Color(UIColor.tertiarySystemFill))
                    .clipShape(RoundedRectangle(cornerRadius: 12))
                    .animation(.easeInOut(duration: 0.15), value: canFinish)
            }
            .buttonStyle(.plain)
            .disabled(!canFinish)

            Button("Not today", action: onNotToday)
                .font(.system(size: 14, weight: .medium))
                .foregroundStyle(Color.secondary)
                .frame(height: 44)
        }
    }
}

#Preview {
    ScheduledSportCard(
        item: ScheduledSport(
            scheduleId: "1",
            day: ScheduleDay(Date()),
            sport: .basketball,
            duration: 5_400
        ),
        onDone: { _, _ in },
        onNotToday: {}
    )
    .padding()
    .background(Color(UIColor.systemGroupedBackground))
}
