//
//  WorkoutSettingsSheet.swift
//  MyDayKit
//
//  Created by Findlay Wood on 08/05/2026.
//

import SwiftUI

struct WorkoutSettingsSheet: View {

    @Environment(\.dismiss) private var dismiss

    /// Visibility and tags bind straight to the builder, so they apply as the
    /// user changes them and survive the sheet closing. They used to be local
    /// `@State` that the template never saw — `buildTemplate()` hardcoded
    /// private with no tags whatever the sheet said.
    @ObservedObject var manager: WorkoutBuilderManager

    @State private var saveToLibrary: Bool = true

    var body: some View {
        NavigationStack {
            ScrollView {
                VStack(spacing: 16) {

                    // MARK: Visibility + Save Row
                    HStack(spacing: 12) {
                        WorkoutSettingsCard(title: "Visibility", icon: "eye") {
                            Toggle(isOn: $manager.isPublic) {
                                Text(manager.isPublic ? "Public" : "Private")
                                    .font(.system(size: 15, weight: .medium))
                            }
                            .tint(Color.darkColor)
                        }

                        WorkoutSettingsCard(title: "Save", icon: "square.and.arrow.down") {
                            Toggle(isOn: $saveToLibrary) {
                                Text(saveToLibrary ? "Yes" : "No")
                                    .font(.system(size: 15, weight: .medium))
                            }
                            .tint(Color.darkColor)
                        }
                    }

                    // MARK: Tags
                    WorkoutSettingsCard(title: "Tags", icon: "tag") {
                        WorkoutTagsField(
                            tags: manager.tags,
                            onAdd: { manager.addTag($0) },
                            onRemove: { manager.removeTag($0) }
                        )
                    }
                }
                .padding(.horizontal, 20)
                .padding(.top, 8)
            }
            .background(Color(.systemGroupedBackground))
            .navigationTitle("Workout Options")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button("Done") { dismiss() }
                        .fontWeight(.semibold)
                }
            }
        }
        .presentationDetents([.medium])
        .presentationDragIndicator(.visible)
        .presentationCornerRadius(24)
    }
}

// MARK: - ChipButton
private struct ChipButton: View {
    let label: String
    let isSelected: Bool
    let action: () -> Void

    var body: some View {
        Button(action: action) {
            Text(label)
                .font(.system(size: 13, weight: .medium))
                .padding(.horizontal, 12)
                .padding(.vertical, 7)
                .background(
                    Capsule()
                        .fill(isSelected ? Color.darkColor : Color(.tertiarySystemBackground))
                )
                .foregroundColor(isSelected ? .white : .secondary)
        }
    }
}

#Preview {
    WorkoutSettingsSheet(manager: WorkoutBuilderManager(uploader: PreviewWorkoutTemplateUploading()))
}
