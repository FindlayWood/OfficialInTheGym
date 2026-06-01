//
//  WorkoutSettingsSheet.swift
//  MyDayKit
//
//  Created by Findlay Wood on 08/05/2026.
//

import SwiftUI

struct WorkoutSettingsSheet: View {

    @Environment(\.dismiss) private var dismiss

    @State private var isPublic: Bool = true
    @State private var saveToLibrary: Bool = true
    @State private var tags: [String] = []
    @State private var tagInput: String = ""
    @FocusState private var tagFieldFocused: Bool

    var body: some View {
        NavigationStack {
            ScrollView {
                VStack(spacing: 16) {

                    // MARK: Visibility + Save Row
                    HStack(spacing: 12) {
                        SettingsCard(title: "Visibility", icon: "eye") {
                            Toggle(isOn: $isPublic) {
                                Text(isPublic ? "Public" : "Private")
                                    .font(.system(size: 15, weight: .medium))
                            }
                            .tint(.accentColor)
                        }

                        SettingsCard(title: "Save", icon: "square.and.arrow.down") {
                            Toggle(isOn: $saveToLibrary) {
                                Text(saveToLibrary ? "Yes" : "No")
                                    .font(.system(size: 15, weight: .medium))
                            }
                            .tint(.accentColor)
                        }
                    }

                    // MARK: Tags
                    SettingsCard(title: "Tags", icon: "tag") {
                        VStack(alignment: .leading, spacing: 10) {
                            HStack(spacing: 8) {
                                TextField("Add a tag...", text: $tagInput)
                                    .focused($tagFieldFocused)
                                    .font(.system(size: 15))
                                    .submitLabel(.done)
                                    .onSubmit { commitTag() }

                                if !tagInput.isEmpty {
                                    Button { commitTag() } label: {
                                        Image(systemName: "return")
                                            .font(.system(size: 13, weight: .semibold))
                                            .foregroundColor(.white)
                                            .frame(width: 28, height: 28)
                                            .background(Circle().fill(Color.accentColor))
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
                                                    tags.removeAll { $0 == tag }
                                                }
                                            } label: {
                                                Image(systemName: "xmark")
                                                    .font(.system(size: 10, weight: .bold))
                                            }
                                        }
                                        .padding(.horizontal, 10)
                                        .padding(.vertical, 6)
                                        .background(Capsule().fill(Color.accentColor.opacity(0.12)))
                                        .foregroundColor(.accentColor)
                                    }
                                }
                                .transition(.opacity.combined(with: .move(edge: .top)))
                            }
                        }
                        .animation(.easeInOut(duration: 0.2), value: tags.count)
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

    private func commitTag() {
        let trimmed = tagInput.trimmingCharacters(in: .whitespaces)
        guard !trimmed.isEmpty, !tags.contains(trimmed) else {
            tagInput = ""
            return
        }
        withAnimation(.spring(response: 0.35, dampingFraction: 0.75)) {
            tags.append(trimmed)
            tagInput = ""
        }
    }
}

// MARK: - SettingsCard
private struct SettingsCard<Content: View>: View {
    let title: String
    let icon: String
    @ViewBuilder let content: Content

    var body: some View {
        VStack(alignment: .leading, spacing: 14) {
            HStack(spacing: 7) {
                Image(systemName: icon)
                    .font(.system(size: 12, weight: .semibold))
                    .foregroundColor(.accentColor)
                Text(title)
                    .font(.system(size: 13, weight: .semibold))
                    .foregroundColor(.secondary)
                    .textCase(.uppercase)
                    .tracking(0.8)
            }
            content
        }
        .padding(16)
        .background(
            RoundedRectangle(cornerRadius: 16, style: .continuous)
                .fill(Color(.secondarySystemBackground))
        )
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
                        .fill(isSelected ? Color.accentColor : Color(.tertiarySystemBackground))
                )
                .foregroundColor(isSelected ? .white : .secondary)
        }
    }
}

// MARK: - FlowLayout
private struct FlowLayout: Layout {
    var spacing: CGFloat = 8

    func sizeThatFits(proposal: ProposedViewSize, subviews: Subviews, cache: inout ()) -> CGSize {
        let width = proposal.width ?? 0
        var height: CGFloat = 0
        var x: CGFloat = 0
        var rowHeight: CGFloat = 0

        for view in subviews {
            let size = view.sizeThatFits(.unspecified)
            if x + size.width > width, x > 0 {
                height += rowHeight + spacing
                x = 0
                rowHeight = 0
            }
            x += size.width + spacing
            rowHeight = max(rowHeight, size.height)
        }
        height += rowHeight
        return CGSize(width: width, height: height)
    }

    func placeSubviews(in bounds: CGRect, proposal: ProposedViewSize, subviews: Subviews, cache: inout ()) {
        var x = bounds.minX
        var y = bounds.minY
        var rowHeight: CGFloat = 0

        for view in subviews {
            let size = view.sizeThatFits(.unspecified)
            if x + size.width > bounds.maxX, x > bounds.minX {
                y += rowHeight + spacing
                x = bounds.minX
                rowHeight = 0
            }
            view.place(at: CGPoint(x: x, y: y), proposal: ProposedViewSize(size))
            x += size.width + spacing
            rowHeight = max(rowHeight, size.height)
        }
    }
}

#Preview {
    WorkoutSettingsSheet()
}
