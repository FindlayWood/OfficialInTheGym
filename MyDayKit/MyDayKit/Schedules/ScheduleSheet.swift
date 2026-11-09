//
//  ScheduleSheet.swift
//  MyDayKit
//
//  Created by Findlay Wood on 08/11/2026.
//

import SwiftUI

/// Sets when a workout or sport falls: one date, or a repeat on chosen weekdays.
///
/// **Save closes it; values do not apply as they change.** Elsewhere the app applies input live, but
/// a half-answered schedule here would put a card on a day nobody chose. Cancel means nothing
/// happened.
///
/// The "Next" line sits above Save so the result can be checked before committing. It is the only
/// place that says what "every two weeks, this week" works out to.
struct ScheduleSheet: View {

    @Environment(\.dismiss) private var dismiss
    @StateObject private var model: ScheduleFormModel

    init(model: @autoclosure @escaping () -> ScheduleFormModel) {
        _model = StateObject(wrappedValue: model())
    }

    var body: some View {
        NavigationStack {
            ScrollView(showsIndicators: false) {
                VStack(spacing: 12) {
                    repeatsCard
                    if model.repeats {
                        repeatCards
                    } else {
                        dateCard
                    }
                    if model.isEditing {
                        stopButton
                    }
                }
                .padding(.horizontal, 20)
                .padding(.top, 8)
                .animation(.easeInOut(duration: 0.15), value: model.repeats)
                .animation(.easeInOut(duration: 0.15), value: model.frequency)
            }
            .background(Color(.systemBackground))
            .safeAreaInset(edge: .bottom) { saveBar }
            .navigationTitle(model.title)
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("Cancel") { dismiss() }
                        .tint(Color.darkColor)
                }
            }
        }
        .presentationDetents([.height(580)])
        .presentationDragIndicator(.visible)
        .presentationCornerRadius(24)
    }

    // MARK: - Cards

    private var repeatsCard: some View {
        ScheduleCard {
            Toggle(isOn: $model.repeats) {
                Text("Repeats")
                    .font(.system(size: 15, weight: .medium))
            }
            .tint(Color.darkColor)
        }
    }

    private var dateCard: some View {
        ScheduleCard(title: "Date") {
            DatePicker(
                "Date",
                selection: $model.date,
                in: model.earliestDate...,
                displayedComponents: .date
            )
            .font(.system(size: 15, weight: .medium))
            .tint(Color.darkColor)
        }
    }

    @ViewBuilder
    private var repeatCards: some View {
        ScheduleCard(title: "How often") {
            ScheduleChoicePicker(
                choices: ScheduleFormModel.Frequency.allCases,
                selection: $model.frequency
            ) { frequency in
                switch frequency {
                case .weekly: return "Weekly"
                case .everyTwoWeeks: return "Every 2 weeks"
                }
            }
        }

        ScheduleCard(title: "Days") {
            ScheduleWeekdayPicker(selected: model.weekdays, onToggle: model.toggle)
        }

        if model.frequency == .everyTwoWeeks {
            ScheduleCard(title: "Starting") {
                ScheduleChoicePicker(
                    choices: ScheduleFormModel.FirstWeek.allCases,
                    selection: $model.firstWeek
                ) { week in
                    switch week {
                    case .this: return "This week"
                    case .next: return "Next week"
                    }
                }
            }
        }
    }

    private var stopButton: some View {
        Button {
            Task {
                if await model.stop() { dismiss() }
            }
        } label: {
            Text("Stop Schedule")
                .font(.system(size: 15, weight: .semibold))
                .foregroundStyle(Color.matteRed)
                .frame(maxWidth: .infinity)
                .frame(height: 44)
        }
        .disabled(model.isSaving)
    }

    // MARK: - Save

    private var saveBar: some View {
        VStack(spacing: 10) {
            if let error = model.saveError {
                Text(error)
                    .font(.system(size: 13, weight: .medium))
                    .foregroundStyle(Color.matteRed)
            }

            Text(model.nextText)
                .font(.system(size: 13, weight: .medium))
                .foregroundStyle(Color.secondary)

            Button {
                Task {
                    if await model.save() { dismiss() }
                }
            } label: {
                Text("Save")
                    .font(.system(size: 17, weight: .semibold))
                    .frame(maxWidth: .infinity)
                    .frame(height: 52)
                    .background(
                        RoundedRectangle(cornerRadius: 14, style: .continuous)
                            .fill(model.canSave ? Color.darkColor : Color(UIColor.tertiarySystemFill))
                    )
                    .foregroundStyle(model.canSave ? Color.white : Color.secondary)
            }
            .buttonStyle(.plain)
            .disabled(!model.canSave)
            .animation(.easeInOut(duration: 0.15), value: model.canSave)
        }
        .padding(.horizontal, 20)
        .padding(.vertical, 12)
        .background(Color(.systemBackground))
    }
}
