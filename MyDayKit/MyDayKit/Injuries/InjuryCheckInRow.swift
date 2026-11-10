//
//  InjuryCheckInRow.swift
//  MyDayKit
//
//  Created by Findlay Wood on 10/11/2026.
//

import SwiftUI

/// One active injury in today's check-in step: rate it, or read today's rating back.
///
/// **Pre-filled from the last check-in**, so a day that feels the same as yesterday is one tap
/// on Save. The values are only a starting point and nothing is stored until Save — an injury
/// left alone today has no check-in today, which is the honest record.
///
/// Once rated, the row collapses to its summary with an Edit, so a list of three injuries
/// does not stay a wall of scales for the rest of the day.
struct InjuryCheckInRow: View {

    let injury: Injury
    let day: ScheduleDay
    let onSave: (_ pain: Int, _ impact: InjuryImpact) -> Void
    let onOptions: () -> Void

    @State private var pain: Int?
    @State private var impact: InjuryImpact?
    @State private var isEditing = false
    @State private var hasSeeded = false

    private var todays: InjuryCheckIn? { injury.checkIn(on: day) }
    private var showsInputs: Bool { todays == nil || isEditing }
    private var canSave: Bool { pain != nil && impact != nil }

    var body: some View {
        VStack(alignment: .leading, spacing: 14) {
            header

            if showsInputs {
                inputs
            } else if let todays {
                summary(todays)
            }
        }
        .padding(16)
        .frame(maxWidth: .infinity, alignment: .leading)
        .background(Color(.secondarySystemGroupedBackground))
        .clipShape(RoundedRectangle(cornerRadius: 16))
        .animation(.spring(response: 0.4, dampingFraction: 0.85), value: showsInputs)
        .onAppear(perform: seedIfNeeded)
    }

    // MARK: - Header

    private var header: some View {
        HStack(spacing: 12) {
            ZStack {
                RoundedRectangle(cornerRadius: 10)
                    .fill(Color.matteRed.opacity(0.12))
                    .frame(width: 40, height: 40)
                Image(systemName: "bandage.fill")
                    .font(.system(size: 17))
                    .foregroundStyle(Color.matteRed)
            }
            VStack(alignment: .leading, spacing: 3) {
                Text(injury.title)
                    .font(.system(size: 16, weight: .semibold))
                    .foregroundStyle(Color.primary)
                Text("Day \(injury.dayNumber(on: day))")
                    .font(.system(size: 13))
                    .foregroundStyle(Color.secondary)
            }
            Spacer(minLength: 0)
            Button(action: onOptions) {
                ZStack {
                    Circle()
                        .fill(Color(.tertiarySystemGroupedBackground))
                        .frame(width: 32, height: 32)
                    Image(systemName: "ellipsis")
                        .font(.system(size: 13, weight: .medium))
                        .foregroundStyle(Color.secondary)
                }
                .frame(width: 44, height: 44)
            }
            .buttonStyle(.plain)
            .accessibilityLabel("Options for \(injury.title)")
        }
    }

    // MARK: - Inputs

    private var inputs: some View {
        VStack(alignment: .leading, spacing: 14) {
            label("PAIN")
            InjuryPainScale(selected: pain) { pain = $0 }

            label("TRAINING")
            InjuryImpactPicker(selected: impact) { impact = $0 }

            Button {
                guard let pain, let impact else { return }
                onSave(pain, impact)
                isEditing = false
            } label: {
                Text(todays == nil ? "Save" : "Update")
                    .font(.system(size: 15, weight: .semibold))
                    .foregroundStyle(canSave ? Color.white : Color.secondary)
                    .frame(maxWidth: .infinity)
                    .frame(height: 44)
                    .background(canSave ? Color.darkColor : Color(UIColor.tertiarySystemFill))
                    .clipShape(RoundedRectangle(cornerRadius: 12))
            }
            .buttonStyle(.plain)
            .disabled(!canSave)
            .animation(.easeInOut(duration: 0.15), value: canSave)
        }
    }

    // MARK: - Summary

    private func summary(_ checkIn: InjuryCheckIn) -> some View {
        HStack(spacing: 10) {
            Circle()
                .fill(InjuryPainScale.color(for: checkIn.pain))
                .frame(width: 10, height: 10)
            Text(checkIn.summary)
                .font(.system(size: 14, weight: .medium))
                .foregroundStyle(Color.primary)
            Spacer(minLength: 0)
            Button("Edit") {
                pain = checkIn.pain
                impact = checkIn.impact
                isEditing = true
            }
            .font(.system(size: 14, weight: .semibold))
            .foregroundStyle(Color.darkColor)
        }
    }

    private func label(_ text: String) -> some View {
        Text(text)
            .font(.system(size: 11, weight: .semibold))
            .foregroundStyle(Color.secondary)
            .tracking(1.2)
    }

    /// Today's values if there are any, else the last day's — once, so a re-render never
    /// clobbers a choice the user has just made.
    private func seedIfNeeded() {
        guard !hasSeeded else { return }
        hasSeeded = true
        let seed = todays ?? injury.latestCheckIn(before: day)
        pain = seed?.pain
        impact = seed?.impact
    }
}
