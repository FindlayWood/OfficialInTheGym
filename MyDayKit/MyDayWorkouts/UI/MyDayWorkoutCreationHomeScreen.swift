//
//  MyDayWorkoutCreationHomeScreen.swift
//  MyDayKit
//
//  Created by Findlay Wood on 25/04/2026.
//

import SwiftUI

struct MyDayWorkoutCreationHomeScreen: View {
    
    @ObservedObject var manager: WorkoutBuilderManager
    @FocusState private var isFocused: Bool
    
    private var titleSuggestions: [String] {
        let formatter = DateFormatter()
        formatter.dateFormat = "EEEE"
        let day = formatter.string(from: Date())
        return [
            "\(day) Upper",
            "\(day) Lower",
            "\(day) Full Body",
            "\(day) Strength",
            "\(day) Recovery",
            "\(day) Cardio",
            "\(day) Mixed",
            "\(day) Push",
            "\(day) Pull",
            "\(day) Legs",
        ]
    }
    
    private var showSuggestions: Bool {
        manager.title.isEmpty || isFocused
    }
    
    private var canUpload: Bool {
        !manager.title.isEmpty && !manager.exercises.isEmpty
    }

    private var isUploading: Bool {
        if case .uploading = manager.uploadState { return true }
        return false
    }
    
    var onOptionsTapped: (() -> ())?
    var addExerciseTapped: (() -> ())?
    var uploadComplete: (() -> ())?
    var onBack: (() -> ())?

    @Namespace private var animation

    /// The spring the cards pull together and apart on, and remove on.
    private let linkAnimation: Animation = .spring(response: 0.42, dampingFraction: 0.78)

    var body: some View {
        ZStack {
            VStack(spacing: 0) {
                // The system bar is hidden (`NavBarHidingHostingController`), as on the workout
                // page, so the builder and the page it makes share one bar and one page colour.
                MyDayWorkoutNavBar(
                    title: "Create Workout",
                    showsOptions: true,
                    onBack: { onBack?() },
                    onOptions: { onOptionsTapped?() }
                )

                titleSection
                    .padding(.horizontal, 20)
                    .padding(.vertical, 14)
                    .background(Color(UIColor.systemBackground))

                Divider()

                exercisesSection
                    .background(Color.pageColor)
            }
            .safeAreaInset(edge: .bottom) {
                uploadBar
            }

            if isUploading {
                uploadingOverlay
            }
        }
        .onChange(of: manager.uploadState) { _, newState in
            if case .success = newState {
                uploadComplete?()
            }
        }
    }

    // MARK: - Title

    private var titleSection: some View {
        VStack(alignment: .leading, spacing: 8) {
            Text("Workout Title")
                .font(.system(size: 12, weight: .semibold))
                .foregroundColor(.secondary)
                .textCase(.uppercase)
                .tracking(1.2)

            HStack(spacing: 12) {
                Image(systemName: "figure.strengthtraining.traditional")
                    .foregroundColor(.secondary)
                    .font(.system(size: 16, weight: .medium))

                TextField("Workout title...", text: $manager.title)
                    .tint(Color.darkColor)
                    .focused($isFocused)
                    .font(.system(size: 17, weight: .medium))
                    .submitLabel(.done)

                if !manager.title.isEmpty {
                    Button {
                        manager.title = ""
                        isFocused = false
                    } label: {
                        Image(systemName: "xmark.circle.fill")
                            .foregroundStyle(Color.darkColor)
                            .font(.system(size: 18))
                    }
                    .transition(.scale.combined(with: .opacity))
                }
            }
            .padding(.horizontal, 16)
            .padding(.vertical, 14)
            .background(
                RoundedRectangle(cornerRadius: 14, style: .continuous)
                    .fill(Color(.secondarySystemBackground))
                    .overlay(
                        RoundedRectangle(cornerRadius: 14, style: .continuous)
                            .strokeBorder(
                                isFocused ? Color.darkColor.opacity(0.6) : Color.clear,
                                lineWidth: 1.5
                            )
                    )
            )
            .animation(.easeInOut(duration: 0.2), value: manager.title.isEmpty)
            .animation(.easeInOut(duration: 0.15), value: isFocused)

            if showSuggestions {
                ScrollView(.horizontal, showsIndicators: false) {
                    HStack(spacing: 8) {
                        ForEach(titleSuggestions, id: \.self) { suggestion in
                            Button {
                                withAnimation(.easeInOut(duration: 0.2)) {
                                    manager.title = suggestion
                                    isFocused = false
                                }
                            } label: {
                                Text(suggestion)
                                    .font(.system(size: 13, weight: .medium))
                                    .foregroundColor(.darkColor)
                                    .padding(.horizontal, 12)
                                    .padding(.vertical, 7)
                                    .background(Capsule().fill(Color.darkColor.opacity(0.1)))
                            }
                        }
                    }
                    .padding(.horizontal, 20)
                    .padding(.vertical, 2)
                }
                .padding(.horizontal, -20)
                .transition(.opacity.combined(with: .move(edge: .top)))
            }
        }
    }

    // MARK: - Exercises

    private var exercisesSection: some View {
        ScrollViewReader { proxy in
            ScrollView(showsIndicators: false) {
                VStack(alignment: .leading, spacing: 0) {
                    exercisesHeader
                        .padding(.bottom, 10)

                    if manager.exercises.isEmpty {
                        // A slot, not a card — the same dashed outline MyDay draws for a step
                        // that has not happened yet.
                        MyDayTimelinePlaceholder(
                            title: "No exercises yet",
                            subtitle: "Add the first one to start building",
                            actionTitle: "Add Exercise",
                            actionLabelColor: .darkColor,
                            action: { addExerciseTapped?() }
                        )
                        .transition(.opacity)
                    } else {
                        exerciseCards

                        MyDayTimelinePlaceholder(
                            title: "Add another exercise",
                            subtitle: "From the library, or one of your own",
                            actionTitle: "Add",
                            actionLabelColor: .darkColor,
                            action: { addExerciseTapped?() }
                        )
                        .padding(.top, 16)
                        .id("addSlot")
                    }
                }
                .padding(16)
            }
            .onChange(of: manager.exercises.count) { old, new in
                guard new > old else { return }
                withAnimation(.easeOut(duration: 0.3)) {
                    proxy.scrollTo("addSlot", anchor: .bottom)
                }
            }
        }
    }

    private var exercisesHeader: some View {
        HStack(alignment: .firstTextBaseline) {
            Text("Exercises")
                .font(.system(size: 12, weight: .semibold))
                .foregroundStyle(Color.white.opacity(0.75))
                .textCase(.uppercase)
                .tracking(1.2)
            Spacer()
            if manager.exercises.count > 1 {
                Text("Link two to make a superset")
                    .font(.system(size: 12, weight: .medium))
                    .foregroundStyle(Color.white.opacity(0.6))
            }
        }
        .padding(.horizontal, 4)
    }

    /// Each exercise its own card, with a `MyDayWorkoutBuilderLinkJoint` between each pair. Linked
    /// cards close the gap and meet at a seam, so a superset reads as one card.
    private var exerciseCards: some View {
        let layout = manager.supersetLayout
        let count = manager.exercises.count
        return VStack(spacing: 0) {
            ForEach(Array(manager.exercises.enumerated()), id: \.element) { index, exercise in
                let linkedToNext = manager.isLinkedToNext(exercise)
                let linkedFromPrevious = index > 0 && manager.isLinkedToNext(manager.exercises[index - 1])

                MyDayWorkoutBuilderExerciseCard(
                    exercise: exercise,
                    supersetEntry: layout.hasSupersets ? layout.entries[index] : nil,
                    joinsPrevious: linkedFromPrevious,
                    joinsNext: linkedToNext && index < count - 1,
                    animation: animation,
                    onRemove: {
                        withAnimation(linkAnimation) {
                            manager.removeExercises(atOffsets: [index])
                        }
                    }
                )
                .transition(.scale(scale: 0.95).combined(with: .opacity))

                if index < count - 1 {
                    MyDayWorkoutBuilderLinkJoint(isLinked: linkedToNext) {
                        withAnimation(linkAnimation) {
                            manager.toggleLink(after: exercise)
                        }
                    }
                    // Its badge overhangs both cards; drawn above them so neither covers it.
                    .zIndex(1)
                }
            }
        }
    }

    // MARK: - Upload

    private var uploadBar: some View {
        Button {
            Task {
                await manager.uploadWorkout()
            }
        } label: {
            HStack(spacing: 10) {
                Image(systemName: "arrow.up.circle.fill")
                    .font(.system(size: 18, weight: .semibold))
                Text("Upload")
                    .font(.system(size: 17, weight: .semibold))
            }
            .frame(maxWidth: .infinity)
            .frame(height: 52)
            .background(
                RoundedRectangle(cornerRadius: 14, style: .continuous)
                    .fill(canUpload ? Color.darkColor : Color(.tertiarySystemFill))
            )
            .foregroundColor(canUpload ? .white : .secondary)
        }
        .disabled(!canUpload || isUploading)
        .animation(.easeInOut(duration: 0.15), value: canUpload)
        .padding(.horizontal, 20)
        .padding(.vertical, 12)
        .background(Color(UIColor.systemBackground).ignoresSafeArea(edges: .bottom))
    }

    private var uploadingOverlay: some View {
        ZStack {
            Color.black.opacity(0.4)
                .ignoresSafeArea()

            VStack(spacing: 20) {
                ProgressView()
                    .progressViewStyle(.circular)
                    .tint(.white)
                    .scaleEffect(1.3)

                Text("Uploading Workout…")
                    .font(.system(size: 16, weight: .semibold))
                    .foregroundColor(.white)
            }
            .padding(36)
            .background(
                RoundedRectangle(cornerRadius: 20, style: .continuous)
                    .fill(.ultraThinMaterial)
            )
        }
        .transition(.opacity)
    }
}

#Preview {
    MyDayWorkoutCreationHomeScreen(
        manager: WorkoutBuilderManager(
            uploader: PreviewWorkoutTemplateUploading()
        )
    )
}
