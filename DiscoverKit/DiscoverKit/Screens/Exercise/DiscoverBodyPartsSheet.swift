//
//  DiscoverBodyPartsSheet.swift
//  DiscoverKit
//
//  Created by Findlay Wood on 25/10/2026.
//

import SwiftUI

/// Suggesting what an exercise works: the same muscle group and movement
/// pattern chips as MyDay's custom exercise form, pre-filled with the user's
/// last suggestion or else the current values. Each tap saves the whole set
/// once it has one of each, so Done only dismisses.
///
/// It says plainly that this is a suggestion: a curator reviews every one, and
/// nothing changes for anyone until they do.
struct DiscoverBodyPartsSheet: View {

    @ObservedObject var viewModel: DiscoverBodyPartsViewModel
    @Environment(\.dismiss) private var dismiss

    var body: some View {
        VStack(alignment: .leading, spacing: 0) {
            HStack(alignment: .top) {
                VStack(alignment: .leading, spacing: 3) {
                    Text("Suggest a change")
                        .font(.system(size: 16, weight: .semibold))
                    Text("A reviewer checks every suggestion before anything changes")
                        .font(.system(size: 13))
                        .foregroundStyle(.secondary)
                }
                Spacer()
                Button("Done") { dismiss() }
                    .font(.system(size: 15, weight: .semibold))
                    .foregroundStyle(Color.darkColor)
            }
            .padding(20)

            Divider()

            ScrollView {
                VStack(alignment: .leading, spacing: 18) {
                    if let parts = viewModel.parts {
                        heading("MUSCLE GROUPS")
                        DiscoverFlowLayout {
                            ForEach(parts.muscleGroups) { part in
                                chip(part.name, isSelected: viewModel.draftMuscleGroups.contains(part.id)) {
                                    Task { await viewModel.toggleMuscleGroup(part.id) }
                                }
                            }
                        }
                        heading("MOVEMENT PATTERNS")
                        DiscoverFlowLayout {
                            ForEach(parts.movementPatterns) { part in
                                chip(part.name, isSelected: viewModel.draftMovementPatterns.contains(part.id)) {
                                    Task { await viewModel.toggleMovementPattern(part.id) }
                                }
                            }
                        }
                    }
                    if !viewModel.isDraftComplete {
                        note("Pick at least one muscle group and one movement pattern.")
                    }
                    if let error = viewModel.saveError {
                        note(error)
                    }
                }
                .padding(20)
            }
        }
    }

    private func heading(_ text: String) -> some View {
        Text(text)
            .font(.system(size: 12, weight: .semibold))
            .foregroundStyle(.secondary)
    }

    private func note(_ text: String) -> some View {
        Text(text)
            .font(.system(size: 13))
            .foregroundStyle(.secondary)
    }

    private func chip(_ title: String, isSelected: Bool, action: @escaping () -> Void) -> some View {
        Button(action: action) {
            Text(title)
                .font(.system(size: 13, weight: .semibold))
                .foregroundStyle(isSelected ? Color.white : Color.primary)
                .padding(.horizontal, 14)
                .padding(.vertical, 8)
                .background(
                    Capsule().fill(isSelected ? Color.darkColor : Color(UIColor.tertiarySystemGroupedBackground))
                )
        }
        .buttonStyle(.plain)
        .animation(.easeInOut(duration: 0.15), value: isSelected)
    }
}
