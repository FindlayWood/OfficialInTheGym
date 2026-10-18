//
//  MyDayWeekCard.swift
//  MyDayKit
//
//  Created by Findlay Wood on 18/10/2026.
//

import SwiftUI

/// The week around a past day with nothing on it, with each day's markers and a count of the
/// days trained. **A missed day means little on its own** — one blank day in an otherwise full
/// week and the third blank day running are different stories, and the day's own screen cannot
/// tell them apart. Tapping a day opens it.
///
/// It reads `MyDayManager.dayMarkers`, which the date strip already loads, so it costs no reads
/// of its own and stays live as days change.
///
/// **Weeks run Monday to Sunday, pinned** rather than following `Calendar.firstWeekday`, as
/// StatsKit's `ActivityGrid` is, so the same day never moves column with the device's region.
/// Days are in the device calendar, the calendar day files are named in. Days outside the strip's
/// window have no markers loaded and cannot be reached from the strip, so they draw dimmed and
/// inert rather than as days with nothing on them.
struct MyDayWeekCard: View {
    let date: Date
    let reachable: ClosedRange<Date>
    let markers: (Date) -> MyDayDayMarkers
    let onSelect: (Date) -> Void

    private let calendar = Calendar.current

    var body: some View {
        let days = weekDays
        let counted = days.filter { reachable.contains($0) }
        let trained = counted.filter { markers($0).hasExercise }.count

        VStack(alignment: .leading, spacing: 10) {
            HStack {
                Text("That week")
                    .font(.system(size: 15, weight: .semibold))
                    .foregroundStyle(Color.primary)
                Spacer()
                Text("\(trained) of \(counted.count) days trained")
                    .font(.system(size: 12, weight: .regular))
                    .foregroundStyle(Color.secondary)
            }

            HStack(spacing: 5) {
                ForEach(days, id: \.self) { day in
                    MyDayWeekDayCell(
                        date: day,
                        markers: markers(day),
                        isCurrent: calendar.isDate(day, inSameDayAs: date),
                        isReachable: reachable.contains(day),
                        onTap: { onSelect(day) }
                    )
                }
            }

            Text("Tap a day to open it")
                .font(.system(size: 12, weight: .regular))
                .foregroundStyle(Color.secondary)
        }
        .padding(16)
        .background(Color(UIColor.secondarySystemGroupedBackground))
        .clipShape(RoundedRectangle(cornerRadius: 16))
    }

    /// Monday to Sunday of the week holding `date`, each at the start of its day.
    private var weekDays: [Date] {
        let day = calendar.startOfDay(for: date)
        // weekday: 1 = Sunday … 7 = Saturday. Days back to Monday: Mon 0, Tue 1 … Sun 6.
        let sinceMonday = (calendar.component(.weekday, from: day) + 5) % 7
        guard let monday = calendar.date(byAdding: .day, value: -sinceMonday, to: day) else { return [] }
        return (0..<7).compactMap { calendar.date(byAdding: .day, value: $0, to: monday) }
    }
}
