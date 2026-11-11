//
//  InjuryAddSheet.swift
//  MyDayKit
//
//  Created by Findlay Wood on 10/11/2026.
//

import SwiftUI

/// "Anything bothering you?" — where it is, which side, and when it started. Two taps for the
/// common case (a region, a side), since the start defaults to today.
///
/// **The start can be back-dated** — a hamstring that went on Saturday is usually only logged on
/// Monday, and reading training against an injury later needs the day it actually started.
/// Never in the future.
struct InjuryAddSheet: View {

    let today: ScheduleDay
    let onAdd: (_ region: InjuryRegion, _ side: InjurySide?, _ startedOn: ScheduleDay, _ note: String?) -> Void
    let onClose: () -> Void

    @State private var region: InjuryRegion?
    @State private var side: InjurySide?
    @State private var startDate = Date()
    @State private var note = ""

    private var needsSide: Bool { region?.hasSide ?? false }
    private var canAdd: Bool { region != nil && (!needsSide || side != nil) }

    var body: some View {
        VStack(spacing: 0) {
            header

            ScrollView {
                VStack(alignment: .leading, spacing: 22) {
                    section("WHERE") { regionGrid }
                    if needsSide {
                        section("SIDE") { sidePicker }
                            .transition(.opacity)
                    }
                    section("STARTED") { startRow }
                    section("NOTE") { noteField }
                }
                .padding(20)
                .animation(.easeInOut(duration: 0.2), value: needsSide)
            }

            addButton
        }
        .background(Color(.systemBackground).ignoresSafeArea())
    }

    // MARK: - Header

    private var header: some View {
        HStack(alignment: .top) {
            VStack(alignment: .leading, spacing: 4) {
                Text("Anything bothering you?")
                    .font(.system(size: 20, weight: .bold))
                Text("Rate it each morning in your check-in.")
                    .font(.system(size: 13, weight: .medium))
                    .foregroundStyle(Color.secondary)
            }
            Spacer()
            Button(action: onClose) {
                Image(systemName: "xmark")
                    .font(.system(size: 14, weight: .semibold))
                    .foregroundStyle(Color.secondary)
                    .frame(width: 36, height: 36)
                    .background(Circle().fill(Color(.secondarySystemFill)))
            }
            .buttonStyle(.plain)
            .accessibilityLabel("Close")
        }
        .padding(.horizontal, 20)
        .padding(.top, 20)
    }

    // MARK: - Sections

    private func section<Content: View>(_ title: String, @ViewBuilder content: () -> Content) -> some View {
        VStack(alignment: .leading, spacing: 10) {
            Text(title)
                .font(.system(size: 11, weight: .semibold))
                .foregroundStyle(Color.secondary)
                .tracking(1.2)
            content()
        }
    }

    private var regionGrid: some View {
        LazyVGrid(columns: [GridItem(.adaptive(minimum: 96), spacing: 8)], spacing: 8) {
            ForEach(InjuryRegion.allCases, id: \.self) { candidate in
                chip(
                    title: candidate.name.prefix(1).uppercased() + candidate.name.dropFirst(),
                    isSelected: candidate == region
                ) {
                    region = candidate
                    if !candidate.hasSide { side = nil }
                }
            }
        }
    }

    private var sidePicker: some View {
        HStack(spacing: 8) {
            ForEach(InjurySide.allCases, id: \.self) { candidate in
                chip(title: candidate.title, isSelected: candidate == side) {
                    side = candidate
                }
            }
        }
    }

    private var startRow: some View {
        HStack {
            Text(startSummary)
                .font(.system(size: 15, weight: .medium))
            Spacer()
            DatePicker("Started", selection: $startDate, in: ...Date(), displayedComponents: .date)
                .labelsHidden()
                .tint(Color.darkColor)
        }
        .padding(.horizontal, 14)
        .frame(minHeight: 52)
        .background(
            RoundedRectangle(cornerRadius: 14, style: .continuous)
                .fill(Color(.secondarySystemBackground))
        )
    }

    private var noteField: some View {
        TextField("What happened? (optional)", text: $note, axis: .vertical)
            .font(.system(size: 15))
            .lineLimit(1...3)
            .tint(Color.darkColor)
            .padding(14)
            .background(
                RoundedRectangle(cornerRadius: 14, style: .continuous)
                    .fill(Color(.secondarySystemBackground))
            )
    }

    private var startSummary: String {
        let day = ScheduleDay(startDate)
        if day == today { return "Today" }
        if day == today.adding(days: -1) { return "Yesterday" }
        return "Earlier"
    }

    private func chip(title: String, isSelected: Bool, action: @escaping () -> Void) -> some View {
        Button(action: action) {
            Text(title)
                .font(.system(size: 14, weight: .semibold))
                .lineLimit(1)
                .minimumScaleFactor(0.85)
                .frame(maxWidth: .infinity)
                .frame(height: 40)
                .background(
                    RoundedRectangle(cornerRadius: 12, style: .continuous)
                        .fill(isSelected ? Color.darkColor : Color(.secondarySystemBackground))
                )
                .foregroundStyle(isSelected ? Color.white : Color.primary)
        }
        .buttonStyle(.plain)
        .accessibilityAddTraits(isSelected ? .isSelected : [])
    }

    // MARK: - Add

    private var addButton: some View {
        Button {
            guard let region else { return }
            let started = min(ScheduleDay(startDate), today)
            onAdd(region, needsSide ? side : nil, started, note)
        } label: {
            Text("Add")
                .font(.system(size: 16, weight: .semibold))
                .foregroundStyle(canAdd ? Color.white : Color.secondary)
                .frame(maxWidth: .infinity)
                .frame(height: 52)
                .background(canAdd ? Color.darkColor : Color(UIColor.tertiarySystemFill))
                .clipShape(RoundedRectangle(cornerRadius: 14))
        }
        .buttonStyle(.plain)
        .disabled(!canAdd)
        .animation(.easeInOut(duration: 0.15), value: canAdd)
        .padding(.horizontal, 20)
        .padding(.bottom, 12)
    }
}

#Preview {
    InjuryAddSheet(today: ScheduleDay(Date()), onAdd: { _, _, _, _ in }, onClose: {})
}
