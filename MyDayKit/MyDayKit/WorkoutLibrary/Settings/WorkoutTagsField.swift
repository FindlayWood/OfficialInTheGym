//
//  WorkoutTagsField.swift
//  MyDayKit
//
//  Created by Findlay Wood on 13/11/2026.
//

import SwiftUI

/// The tag input and the tags already added, as removable chips. Moved out of
/// `WorkoutSettingsSheet` so the builder and the workout page share it: **one field, one rule.**
/// It normalises as the user types (`WorkoutTag.normalized`), so the box never shows a tag that
/// would be stored differently, and hands the tag up to be added through `WorkoutTag.appending`.
struct WorkoutTagsField: View {

    let tags: [String]
    let onAdd: (String) -> Void
    let onRemove: (String) -> Void

    @State private var tagInput: String = ""
    @FocusState private var tagFieldFocused: Bool

    var body: some View {
        VStack(alignment: .leading, spacing: 10) {
            HStack(spacing: 8) {
                TextField("Add a tag...", text: $tagInput)
                    .tint(Color.darkColor)
                    .focused($tagFieldFocused)
                    .font(.system(size: 15))
                    .submitLabel(.done)
                    .textInputAutocapitalization(.never)
                    .autocorrectionDisabled()
                    .onChange(of: tagInput) { _, newValue in
                        let normalized = WorkoutTag.normalized(newValue)
                        if normalized != newValue { tagInput = normalized }
                    }
                    .onSubmit { commitTag() }

                if !tagInput.isEmpty {
                    Button { commitTag() } label: {
                        Image(systemName: "return")
                            .font(.system(size: 13, weight: .semibold))
                            .foregroundColor(.white)
                            .frame(width: 28, height: 28)
                            .background(Circle().fill(Color.darkColor))
                    }
                    .transition(.scale.combined(with: .opacity))
                }
            }
            .padding(.horizontal, 12)
            .padding(.vertical, 10)
            .background(
                RoundedRectangle(cornerRadius: 10, style: .continuous)
                    .fill(Color(.tertiarySystemBackground))
            )
            .animation(.easeInOut(duration: 0.15), value: tagInput.isEmpty)

            if !tags.isEmpty {
                FlowLayout(spacing: 8) {
                    ForEach(tags, id: \.self) { tag in
                        HStack(spacing: 5) {
                            Text(tag)
                                .font(.system(size: 13, weight: .medium))
                            Button {
                                withAnimation(.easeInOut(duration: 0.15)) {
                                    onRemove(tag)
                                }
                            } label: {
                                Image(systemName: "xmark")
                                    .font(.system(size: 10, weight: .bold))
                            }
                        }
                        .padding(.horizontal, 10)
                        .padding(.vertical, 6)
                        .background(Capsule().fill(Color.darkColor.opacity(0.12)))
                        .foregroundColor(Color.darkColor)
                    }
                }
                .transition(.opacity.combined(with: .move(edge: .top)))
            }
        }
        .animation(.easeInOut(duration: 0.2), value: tags.count)
    }

    private func commitTag() {
        withAnimation(.spring(response: 0.35, dampingFraction: 0.75)) {
            onAdd(tagInput)
            tagInput = ""
        }
    }
}
