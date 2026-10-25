//
//  CustomExerciseFormScreen.swift
//  MyDayKit
//
//  Created by Findlay Wood on 25/10/2026.
//

import SwiftUI

/// Makes an exercise the catalogue lacks. One form on MyDay's builder
/// vocabulary — `secondarySystemBackground` cards, uppercase caption headers,
/// one 52pt button pinned to the bottom, gated like `SessionSetDetailOverlay`'s.
///
/// **Save stays disabled until every answer is given**, and each section says
/// what it needs, so the user is never left wondering why. The name says it
/// cannot be changed once saved: raw logs, templates and stats each keep the
/// name they were written with, so a rename would split one exercise's history.
struct CustomExerciseFormScreen: View {

    @StateObject var model: CustomExerciseFormModel
    @FocusState private var nameFocused: Bool

    /// Called with the saved exercise; the coordinator carries on as if it had
    /// been picked.
    var onSaved: (@MainActor (CustomExercise) -> Void)?

    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 24) {
                nameSection
                categorySection
                optionSections
                twoOptionSection(
                    title: "Joints",
                    selection: $model.isCompound,
                    yes: ("Compound", "Several joints, like a squat"),
                    no: ("Single joint", "One joint, like a curl")
                )
                twoOptionSection(
                    title: "Sides",
                    selection: $model.isUnilateral,
                    yes: ("One side", "One side at a time, like a split squat"),
                    no: ("Both sides", "Both together, like a squat")
                )
            }
            .padding(16)
        }
        .scrollDismissesKeyboard(.interactively)
        .background(Color(UIColor.systemBackground))
        .safeAreaInset(edge: .bottom) { bottomBar }
        .navigationTitle("New Exercise")
        .navigationBarTitleDisplayMode(.inline)
        .task { await model.loadOptions() }
    }

    // MARK: - Name

    private var nameSection: some View {
        VStack(alignment: .leading, spacing: 8) {
            sectionHeader("Name")

            TextField("Exercise name", text: $model.name)
                .tint(Color.darkColor)
                .focused($nameFocused)
                .font(.system(size: 17, weight: .medium))
                .submitLabel(.done)
                .padding(.horizontal, 16)
                .padding(.vertical, 14)
                .background(
                    RoundedRectangle(cornerRadius: 14, style: .continuous)
                        .fill(Color(UIColor.secondarySystemBackground))
                        .overlay(
                            RoundedRectangle(cornerRadius: 14, style: .continuous)
                                .strokeBorder(nameFocused ? Color.darkColor.opacity(0.6) : Color.clear, lineWidth: 1.5)
                        )
                )
                .animation(.easeInOut(duration: 0.15), value: nameFocused)

            Label("The name can't be changed after saving.", systemImage: "lock")
                .font(.system(size: 12, weight: .medium))
                .foregroundStyle(Color.secondary)
        }
    }

    // MARK: - Category

    private var categorySection: some View {
        VStack(alignment: .leading, spacing: 8) {
            sectionHeader("Category")
            FlowLayout {
                ForEach(ExerciseCategory.allCases, id: \.self) { category in
                    chip(category.title, isSelected: model.category == category) {
                        model.category = category
                    }
                }
            }
        }
    }

    // MARK: - Muscle groups and movement patterns

    @ViewBuilder
    private var optionSections: some View {
        switch model.options {
        case .loading:
            VStack(alignment: .leading, spacing: 8) {
                sectionHeader("Muscle groups")
                ProgressView()
                    .frame(maxWidth: .infinity)
                    .padding(.vertical, 24)
            }
        case .failed:
            VStack(alignment: .leading, spacing: 8) {
                sectionHeader("Muscle groups")
                VStack(spacing: 10) {
                    Text("Couldn't load muscle groups and movement patterns.")
                        .font(.system(size: 14, weight: .medium))
                        .foregroundStyle(Color.secondary)
                        .multilineTextAlignment(.center)
                    Button("Try Again") {
                        Task { await model.loadOptions() }
                    }
                    .font(.system(size: 14, weight: .semibold))
                    .foregroundStyle(Color.darkColor)
                }
                .frame(maxWidth: .infinity)
                .padding(16)
                .background(RoundedRectangle(cornerRadius: 14).fill(Color(UIColor.secondarySystemBackground)))
            }
        case let .loaded(groups, patterns):
            VStack(alignment: .leading, spacing: 8) {
                sectionHeader("Muscle groups", hint: "Pick at least one")
                ForEach(regions(of: groups), id: \.title) { region in
                    Text(region.title)
                        .font(.system(size: 13, weight: .semibold))
                        .foregroundStyle(Color.secondary)
                        .padding(.top, 4)
                    FlowLayout {
                        ForEach(region.groups) { group in
                            chip(group.name, isSelected: model.muscleGroups.contains(group.id)) {
                                model.toggleMuscleGroup(group.id)
                            }
                        }
                    }
                }
            }
            VStack(alignment: .leading, spacing: 8) {
                sectionHeader("Movement patterns", hint: "Pick at least one")
                FlowLayout {
                    ForEach(patterns) { pattern in
                        chip(pattern.name, isSelected: model.movementPatterns.contains(pattern.id)) {
                            model.toggleMovementPattern(pattern.id)
                        }
                    }
                }
            }
        }
    }

    /// Muscle groups under their region, in `ExerciseCategory`'s order, with
    /// any the app cannot place last rather than dropped.
    private func regions(of groups: [ExerciseMuscleGroup]) -> [(title: String, groups: [ExerciseMuscleGroup])] {
        var result = ExerciseCategory.allCases.compactMap { category -> (title: String, groups: [ExerciseMuscleGroup])? in
            let matching = groups.filter { $0.category == category }
            return matching.isEmpty ? nil : (category.title, matching)
        }
        let unplaced = groups.filter { $0.category == nil }
        if !unplaced.isEmpty {
            result.append(("Other", unplaced))
        }
        return result
    }

    // MARK: - Two-option questions

    /// Two cards, neither selected until the user picks one.
    private func twoOptionSection(
        title: String,
        selection: Binding<Bool?>,
        yes: (title: String, detail: String),
        no: (title: String, detail: String)
    ) -> some View {
        VStack(alignment: .leading, spacing: 8) {
            sectionHeader(title)
            HStack(spacing: 10) {
                optionCard(yes, isSelected: selection.wrappedValue == true) { selection.wrappedValue = true }
                optionCard(no, isSelected: selection.wrappedValue == false) { selection.wrappedValue = false }
            }
        }
    }

    private func optionCard(
        _ option: (title: String, detail: String),
        isSelected: Bool,
        action: @escaping () -> Void
    ) -> some View {
        Button(action: action) {
            VStack(alignment: .leading, spacing: 4) {
                Text(option.title)
                    .font(.system(size: 15, weight: .semibold))
                    .foregroundStyle(isSelected ? Color.white : Color.primary)
                Text(option.detail)
                    .font(.system(size: 12, weight: .regular))
                    .foregroundStyle(isSelected ? Color.white.opacity(0.8) : Color.secondary)
                    .multilineTextAlignment(.leading)
                    .fixedSize(horizontal: false, vertical: true)
            }
            .frame(maxWidth: .infinity, minHeight: 64, alignment: .topLeading)
            .padding(12)
            .background(
                RoundedRectangle(cornerRadius: 14)
                    .fill(isSelected ? Color.darkColor : Color(UIColor.secondarySystemBackground))
            )
        }
        .buttonStyle(.plain)
        .animation(.easeInOut(duration: 0.15), value: isSelected)
    }

    // MARK: - Bottom bar

    private var bottomBar: some View {
        VStack(spacing: 10) {
            if let error = model.saveError {
                Text(error)
                    .font(.system(size: 13, weight: .medium))
                    .foregroundStyle(Color.matteRed)
                    .frame(maxWidth: .infinity, alignment: .leading)
            }
            Button {
                Task {
                    if let saved = await model.save() {
                        onSaved?(saved)
                    }
                }
            } label: {
                ZStack {
                    if model.isSaving {
                        ProgressView().tint(Color.white)
                    } else {
                        Text("Save Exercise")
                            .font(.system(size: 16, weight: .semibold))
                    }
                }
                .foregroundStyle(model.canSave ? Color.white : Color.secondary)
                .frame(maxWidth: .infinity)
                .frame(height: 52)
                .background(
                    RoundedRectangle(cornerRadius: 14)
                        .fill(model.canSave || model.isSaving ? Color.darkColor : Color(UIColor.tertiarySystemFill))
                )
            }
            .buttonStyle(.plain)
            .disabled(!model.canSave)
            .animation(.easeInOut(duration: 0.15), value: model.canSave)
        }
        .padding(.horizontal, 16)
        .padding(.top, 8)
        .padding(.bottom, 8)
        .background(Color(UIColor.systemBackground))
    }

    // MARK: - Pieces

    private func sectionHeader(_ title: String, hint: String? = nil) -> some View {
        HStack(alignment: .firstTextBaseline) {
            Text(title)
                .font(.caption)
                .fontWeight(.semibold)
                .foregroundStyle(Color.secondary)
                .textCase(.uppercase)
                .tracking(1.2)
            Spacer()
            if let hint {
                Text(hint)
                    .font(.system(size: 12, weight: .medium))
                    .foregroundStyle(Color(UIColor.tertiaryLabel))
            }
        }
    }

    private func chip(_ title: String, isSelected: Bool, action: @escaping () -> Void) -> some View {
        Button(action: action) {
            Text(title)
                .font(.system(size: 13, weight: .semibold))
                .foregroundStyle(isSelected ? Color.white : Color.primary)
                .padding(.horizontal, 14)
                .padding(.vertical, 8)
                .background(
                    Capsule().fill(isSelected ? Color.darkColor : Color(UIColor.secondarySystemBackground))
                )
        }
        .buttonStyle(.plain)
        .animation(.easeInOut(duration: 0.15), value: isSelected)
    }
}

#Preview {
    NavigationStack {
        CustomExerciseFormScreen(
            model: CustomExerciseFormModel(
                name: "Landmine Press",
                dependencies: CustomExerciseDependencies(
                    saver: PreviewCustomExerciseUploading(),
                    muscleGroups: PreviewExerciseMuscleGroupsLoader(),
                    movementPatterns: PreviewExerciseMovementPatternsLoader(),
                    userId: "preview"
                )
            )
        )
    }
}
