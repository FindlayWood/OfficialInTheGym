//
//  WorkoutTemplateSettingsSheet.swift
//  MyDayKit
//
//  Created by Findlay Wood on 13/11/2026.
//

import SwiftUI

/// A saved workout's visibility and tags, opened from the `⋯` on its page. Built from the same
/// card and tag field as the builder's `WorkoutSettingsSheet`, without its Save toggle, which
/// does nothing there and would mean nothing here.
///
/// **Visibility says what it does**, because here, unlike in the builder, the workout may already
/// be public, rated and commented on. Going private keeps all of that on the server and brings it
/// back if the workout goes public again, so the line promises only what is true: where the
/// workout shows. The sheet saves when it closes (`WorkoutTemplateSettingsEditor`).
struct WorkoutTemplateSettingsSheet: View {

    @Environment(\.dismiss) private var dismiss

    @ObservedObject var editor: WorkoutTemplateSettingsEditor

    var body: some View {
        NavigationStack {
            ScrollView {
                VStack(spacing: 16) {
                    WorkoutSettingsCard(title: "Visibility", icon: editor.isPublic ? "globe" : "lock") {
                        VStack(alignment: .leading, spacing: 8) {
                            Toggle(isOn: $editor.isPublic) {
                                Text(editor.isPublic ? "Public" : "Private")
                                    .font(.system(size: 15, weight: .medium))
                            }
                            .tint(Color.darkColor)

                            Text(visibilityDescription)
                                .font(.system(size: 13))
                                .foregroundStyle(Color.secondary)
                                .fixedSize(horizontal: false, vertical: true)
                        }
                    }

                    WorkoutSettingsCard(title: "Tags", icon: "tag") {
                        WorkoutTagsField(
                            tags: editor.tags,
                            onAdd: { editor.addTag($0) },
                            onRemove: { editor.removeTag($0) }
                        )
                    }
                }
                .padding(.horizontal, 20)
                .padding(.top, 8)
            }
            .background(Color(.systemGroupedBackground))
            .navigationTitle("Workout Settings")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button("Done") { dismiss() }
                        .fontWeight(.semibold)
                        .tint(Color.darkColor)
                }
            }
        }
        .presentationDetents([.medium, .large])
        .presentationDragIndicator(.visible)
        .presentationCornerRadius(24)
    }

    private var visibilityDescription: String {
        editor.isPublic
            ? "Shows on DISCOVER and your profile, where anyone can rate it and save a copy."
            : "Only you can see it. Copies people have already saved stay theirs."
    }
}
