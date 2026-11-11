//
//  MyDayInjurySection.swift
//  MyDayKit
//
//  Created by Findlay Wood on 10/11/2026.
//

import SwiftUI

/// Injuries in today's check-in step: a row for each active one, and a way to add one.
///
/// **Part of the check-in, not a step of its own.** Rating a hamstring is the same morning
/// question as "how does your body feel", and a fourth node on the timeline would make a day
/// with no injury look unfinished. It does not depend on the wellness questions being answered.
///
/// **Today only.** Past days are read-only on MyDay, and an injury's history is what the later
/// STATS page is for (`READINESS_PLAN.md` step 4).
struct MyDayInjurySection: View {

    @ObservedObject var manager: InjuryManager
    let today: ScheduleDay

    @State private var isAdding = false
    @State private var optionsFor: Injury?
    @State private var confirmingRemoval: Injury?

    var body: some View {
        let active = manager.active(on: today)
        VStack(spacing: 10) {
            ForEach(active) { injury in
                InjuryCheckInRow(
                    injury: injury,
                    day: today,
                    onSave: { pain, impact in
                        Task { try? await manager.checkIn(injury, pain: pain, impact: impact, on: today) }
                    },
                    onOptions: { optionsFor = injury }
                )
                .transition(.opacity)
            }

            if active.isEmpty {
                MyDayTimelinePlaceholder(
                    title: "Anything bothering you?",
                    subtitle: "Track a niggle or injury day by day",
                    actionTitle: "Add",
                    actionTint: .white,
                    actionLabelColor: .darkColor,
                    action: { isAdding = true }
                )
            } else {
                Button { isAdding = true } label: {
                    Label("Add another", systemImage: "plus")
                        .font(.system(size: 13, weight: .semibold))
                        .foregroundStyle(Color.white)
                        .frame(maxWidth: .infinity, alignment: .leading)
                        .padding(.vertical, 6)
                        .contentShape(Rectangle())
                }
                .buttonStyle(.plain)
            }
        }
        .animation(.easeInOut(duration: 0.2), value: active.map(\.id))
        .task { await manager.loadIfNeeded() }
        .sheet(isPresented: $isAdding) {
            InjuryAddSheet(
                today: today,
                onAdd: { region, side, startedOn, note in
                    isAdding = false
                    Task { try? await manager.add(region: region, side: side, startedOn: startedOn, note: note) }
                },
                onClose: { isAdding = false }
            )
            .presentationDragIndicator(.visible)
        }
        .sheet(item: $optionsFor) { injury in
            InjuryOptionsSheet(
                title: injury.title,
                onResolve: {
                    optionsFor = nil
                    Task { try? await manager.resolve(injury, on: today) }
                },
                onRemove: {
                    optionsFor = nil
                    confirmingRemoval = injury
                }
            )
            .presentationDetents([.height(210)])
            .presentationDragIndicator(.visible)
        }
        .alert(
            "Remove \(confirmingRemoval?.title ?? "injury")?",
            isPresented: Binding(get: { confirmingRemoval != nil }, set: { if !$0 { confirmingRemoval = nil } })
        ) {
            Button("Remove", role: .destructive) {
                if let injury = confirmingRemoval {
                    Task { try? await manager.remove(injury) }
                }
                confirmingRemoval = nil
            }
            Button("Cancel", role: .cancel) { confirmingRemoval = nil }
        } message: {
            Text("For one added by mistake. If it has cleared up, choose \u{201C}It's cleared up\u{201D} instead to keep its history.")
        }
    }
}
