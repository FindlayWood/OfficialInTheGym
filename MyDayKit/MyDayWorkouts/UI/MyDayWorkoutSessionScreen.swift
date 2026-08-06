//
//  MyDayWorkoutSessionScreen.swift
//  MyDayKit
//
//  Created by Findlay Wood on 27/06/2026.
//

import SwiftUI

struct MyDayWorkoutSessionScreen: View {

    @ObservedObject var manager: WorkoutSessionManager
    let userId: String

    var onGoToSummary: (() -> Void)?
    var onBack: (() -> Void)?
    var onCancelled: (() -> Void)?

    @Namespace private var animation

    @State private var elapsedSeconds = 0
    @State private var rpeExercise: WorkoutExerciseModel?
    @State private var selectedSet: SessionSetDetail?
    @State private var isConfirmingCancel = false

    private let heroAnimation: Animation = .interactiveSpring(response: 0.3, dampingFraction: 0.8, blendDuration: 0.8)

    private var sessionStarted: Bool { manager.sessionStatus != .notStarted }
    private var sessionCompleted: Bool { manager.sessionStatus == .completed }

    var body: some View {
        ZStack(alignment: .bottom) {
            VStack(spacing: 0) {
                WorkoutSessionNavBar(
                    title: manager.entry.template.title,
                    showsOptions: sessionStarted && !sessionCompleted,
                    onBack: { onBack?() },
                    onCancelWorkout: { isConfirmingCancel = true }
                )

                if sessionStarted {
                    if sessionCompleted {
                        completedHeader
                    } else {
                        progressHeader
                        if manager.isRestTimerRunning {
                            restTimerBanner
                                .transition(.move(edge: .top).combined(with: .opacity))
                        }
                    }
                    Divider()
                }

                ScrollView(showsIndicators: false) {
                    LazyVStack(spacing: 12) {
                        ForEach(manager.entry.template.exercises) { exercise in
                            MyDayWorkoutSessionExerciseCard(
                                exercise: exercise,
                                setRecords: manager.setRecords(for: exercise.exerciseId),
                                isSessionStarted: sessionStarted,
                                isSessionCompleted: sessionCompleted,
                                exerciseRPE: manager.exerciseRPE(for: exercise.exerciseId),
                                animation: animation,
                                selectedSetId: selectedSet?.matchedId,
                                // Always available. Before starting, the overlay
                                // is how a set is read in full; after finishing,
                                // it is how it is revisited.
                                onSetTapped: { targetSet, record, index in
                                    withAnimation(heroAnimation) {
                                        selectedSet = SessionSetDetail(
                                            exercise: exercise,
                                            setModel: targetSet,
                                            setRecord: record,
                                            index: index
                                        )
                                    }
                                },
                                onRPETapped: sessionStarted && !sessionCompleted ? {
                                    rpeExercise = exercise
                                } : nil
                            )
                        }
                        Color.clear.frame(height: sessionStarted ? 100 : 200)
                    }
                    .padding(.horizontal, 16)
                    .padding(.vertical, 12)
                }
                .background(Color.darkColor)
            }

            if !sessionStarted {
                WorkoutSessionStartCard(entry: manager.entry, onStart: manager.startSession)
                    .padding(.horizontal, 16)
                    .padding(.bottom, 16)
                    .transition(.move(edge: .bottom).combined(with: .opacity))
            } else if !sessionCompleted {
                WorkoutSessionFinishBar(onFinish: { onGoToSummary?() })
                    .transition(.move(edge: .bottom).combined(with: .opacity))
            }

        }
        .animation(.easeInOut(duration: 0.25), value: manager.isRestTimerRunning)
        .animation(.easeInOut(duration: 0.3), value: sessionStarted)
        .overlay {
            if let selectedSet {
                setDetailOverlay(for: selectedSet)
            }
        }
        .confirmationDialog(
            "Cancel this workout?",
            isPresented: $isConfirmingCancel,
            titleVisibility: .visible
        ) {
            Button("Cancel Workout", role: .destructive) {
                manager.cancelSession()
                onCancelled?()
            }
            Button("Keep Going", role: .cancel) {}
        } message: {
            // `cancelSession()` genuinely discards everything, so the copy has
            // to say so — this is the one place in the flow where leaving does
            // cost the user something.
            Text("This will remove all logged sets and reset the workout. It stays on your day, so you can start it again.")
        }
        .task {
            if sessionStarted {
                elapsedSeconds = Int(Date().timeIntervalSince(manager.startedAt))
            }
            while !Task.isCancelled {
                try? await Task.sleep(nanoseconds: 1_000_000_000)
                if sessionStarted { elapsedSeconds += 1 }
            }
        }
        .sheet(item: $rpeExercise) { exercise in
            WorkoutExerciseRPESheet(
                exerciseName: exercise.exerciseName,
                currentRPE: manager.exerciseRPE(for: exercise.exerciseId),
                onSelect: { rpe in
                    manager.setExerciseRPE(exerciseId: exercise.exerciseId, rpe: rpe)
                    rpeExercise = nil
                }
            )
            .presentationDetents([.height(260)])
            .presentationDragIndicator(.visible)
        }
    }

    // MARK: - Set Detail Overlay

    private func setDetailOverlay(for detail: SessionSetDetail) -> some View {
        // `selectedSet` is captured at tap time; re-read the record from the
        // manager on every render so the overlay reflects what was just logged.
        let live = SessionSetDetail(
            exercise: detail.exercise,
            setModel: detail.setModel,
            setRecord: manager.setRecord(
                exerciseId: detail.exercise.exerciseId,
                setId: detail.setModel.id
            ),
            index: detail.index
        )

        return ZStack {
            Color.black
                .opacity(0.6)
                .ignoresSafeArea()
                .transition(.opacity)
                .onTapGesture {
                    withAnimation(heroAnimation) {
                        selectedSet = nil
                    }
                }

            SessionSetDetailOverlay(
                detail: live,
                mode: SessionSetDetailMode(isStarted: sessionStarted, isCompleted: sessionCompleted),
                animation: animation,
                onLog: { input in
                    log(input, for: live)
                },
                onRemoveLog: {
                    manager.uncompleteSet(
                        exerciseId: live.exercise.exerciseId,
                        setId: live.setModel.id
                    )
                },
                onDismiss: {
                    withAnimation(heroAnimation) {
                        selectedSet = nil
                    }
                }
            )
            .transition(.asymmetric(insertion: .identity, removal: .offset(y: 5)))
            .padding()
        }
    }

    // MARK: - Log

    private func log(_ input: SessionSetInput, for detail: SessionSetDetail) {
        let wasLogged = detail.setRecord?.isCompleted ?? false

        // Weight carries its own unit — the user picks it in the session, so a
        // set prescribed in % of 1RM or Max is stored as the real load lifted.
        // Distance has no picker, so it still falls back to the template's unit
        // and then to metres: the LOGGED grid renders "—" for a value whose
        // unit is nil.
        let distanceUnit = detail.setModel.distanceUnit ?? (input.distance != nil ? .metres : nil)

        manager.completeSet(
            exerciseId: detail.exercise.exerciseId,
            setId: detail.setModel.id,
            reps: input.reps,
            weight: input.weight,
            weightUnit: input.weightUnit,
            time: input.time,
            distance: input.distance,
            distanceUnit: distanceUnit,
            tempo: input.tempo,
            note: input.note
        )

        // Only on first completion — editing an already-logged set must not
        // restart the rest timer.
        if !wasLogged, let rest = detail.exercise.restSeconds, rest > 0 {
            manager.startRestTimer(seconds: rest)
        }
    }

    // MARK: - Completed Header

    private var completedHeader: some View {
        HStack(spacing: 16) {
            VStack(alignment: .leading, spacing: 4) {
                Text("SETS")
                    .font(.system(size: 10, weight: .semibold))
                    .foregroundStyle(Color.secondary)
                    .tracking(1.2)
                HStack(alignment: .lastTextBaseline, spacing: 3) {
                    Text("\(manager.totalSetsLogged)")
                        .font(.system(size: 22, weight: .bold))
                        .foregroundStyle(Color.primary)
                    Text("/ \(manager.totalSetsTargeted)")
                        .font(.system(size: 14, weight: .medium))
                        .foregroundStyle(Color.secondary)
                }
            }

            Spacer()

            HStack(spacing: 6) {
                Image(systemName: "checkmark.circle.fill")
                    .font(.system(size: 14, weight: .semibold))
                    .foregroundStyle(Color.green)
                Text("Completed")
                    .font(.system(size: 13, weight: .semibold))
                    .foregroundStyle(Color.green)
            }

            Spacer()

            VStack(alignment: .trailing, spacing: 4) {
                Text("DURATION")
                    .font(.system(size: 10, weight: .semibold))
                    .foregroundStyle(Color.secondary)
                    .tracking(1.2)
                Text(formattedDuration)
                    .font(.system(size: 18, weight: .semibold, design: .monospaced))
                    .foregroundStyle(Color.primary)
            }
        }
        .padding(.horizontal, 20)
        .padding(.vertical, 14)
    }

    // MARK: - Progress Header

    private var progressHeader: some View {
        HStack(spacing: 16) {
            VStack(alignment: .leading, spacing: 4) {
                Text("SETS")
                    .font(.system(size: 10, weight: .semibold))
                    .foregroundStyle(Color.secondary)
                    .tracking(1.2)
                HStack(alignment: .lastTextBaseline, spacing: 3) {
                    Text("\(manager.totalSetsLogged)")
                        .font(.system(size: 22, weight: .bold))
                        .foregroundStyle(Color.primary)
                        .contentTransition(.numericText())
                        .animation(.easeInOut(duration: 0.2), value: manager.totalSetsLogged)
                    Text("/ \(manager.totalSetsTargeted)")
                        .font(.system(size: 14, weight: .medium))
                        .foregroundStyle(Color.secondary)
                }
            }

            GeometryReader { geo in
                ZStack(alignment: .leading) {
                    RoundedRectangle(cornerRadius: 4)
                        .fill(Color(UIColor.secondarySystemBackground))
                        .frame(height: 6)
                    RoundedRectangle(cornerRadius: 4)
                        .fill(Color.darkColor)
                        .frame(
                            width: manager.totalSetsTargeted > 0
                                ? geo.size.width * CGFloat(manager.totalSetsLogged) / CGFloat(manager.totalSetsTargeted)
                                : 0,
                            height: 6
                        )
                        .animation(.easeInOut(duration: 0.3), value: manager.totalSetsLogged)
                }
            }
            .frame(height: 6)

            VStack(alignment: .trailing, spacing: 4) {
                Text("TIME")
                    .font(.system(size: 10, weight: .semibold))
                    .foregroundStyle(Color.secondary)
                    .tracking(1.2)
                Text(formattedElapsed)
                    .font(.system(size: 18, weight: .semibold, design: .monospaced))
                    .foregroundStyle(Color.primary)
                    .contentTransition(.numericText())
                    .animation(.linear(duration: 0.5), value: elapsedSeconds)
            }
        }
        .padding(.horizontal, 20)
        .padding(.vertical, 14)
    }

    // MARK: - Rest Timer Banner

    private var restTimerBanner: some View {
        HStack(spacing: 16) {
            VStack(alignment: .leading, spacing: 2) {
                Text("REST")
                    .font(.system(size: 10, weight: .bold))
                    .foregroundStyle(Color.orange.opacity(0.8))
                    .tracking(1.5)
                Text(formattedRestTimer)
                    .font(.system(size: 28, weight: .bold, design: .monospaced))
                    .foregroundStyle(Color.orange)
                    .contentTransition(.numericText())
                    .animation(.linear(duration: 0.5), value: manager.restTimerSeconds)
            }

            Spacer()

            Button {
                manager.cancelRestTimer()
            } label: {
                Text("Skip")
                    .font(.system(size: 14, weight: .semibold))
                    .foregroundStyle(Color.orange)
                    .padding(.horizontal, 16)
                    .padding(.vertical, 8)
                    .background(Capsule().fill(Color.orange.opacity(0.12)))
            }
        }
        .padding(.horizontal, 20)
        .padding(.vertical, 12)
        .background(Color.orange.opacity(0.06))
        .overlay(alignment: .bottom) {
            Rectangle()
                .fill(Color.orange.opacity(0.15))
                .frame(height: 1)
        }
    }

    // MARK: - Helpers

    private var formattedDuration: String {
        guard let record = manager.entry.sessionRecord, let endedAt = record.endedAt else { return "--:--" }
        let seconds = Int(endedAt.timeIntervalSince(record.startedAt))
        let h = seconds / 3600
        let m = (seconds % 3600) / 60
        return h > 0
            ? String(format: "%d:%02d", h, m)
            : String(format: "%d:%02d", m, seconds % 60)
    }

    private var formattedElapsed: String {
        let h = elapsedSeconds / 3600
        let m = (elapsedSeconds % 3600) / 60
        let s = elapsedSeconds % 60
        return h > 0
            ? String(format: "%d:%02d", h, m)
            : String(format: "%d:%02d", m, s)
    }

    private var formattedRestTimer: String {
        let m = manager.restTimerSeconds / 60
        let s = manager.restTimerSeconds % 60
        return String(format: "%d:%02d", m, s)
    }
}

// MARK: - Preview

// The real screen is hosted with the navigation bar hidden
// (`WorkoutSessionHostingController`), so no `NavigationStack` here.
#Preview {
    MyDayWorkoutSessionScreen(
            manager: WorkoutSessionManager(
                entry: DailyWorkoutEntry(
                    template: WorkoutTemplateModel(
                        id: "1",
                        title: "Monday Upper",
                        description: nil,
                        exercises: [
                            WorkoutExerciseModel(
                                id: "e1",
                                exerciseId: "bench-press",
                                exerciseName: "Bench Press",
                                exerciseCategory: .upperBody,
                                orderIndex: 0,
                                sets: [
                                    WorkoutSetModel(id: "s1", orderIndex: 0, reps: 8, weight: 80, weightUnit: .kg),
                                    WorkoutSetModel(id: "s2", orderIndex: 1, reps: 8, weight: 80, weightUnit: .kg),
                                    WorkoutSetModel(id: "s3", orderIndex: 2, reps: 6, weight: 85, weightUnit: .kg)
                                ],
                                restSeconds: 90
                            ),
                            WorkoutExerciseModel(
                                id: "e2",
                                exerciseId: "pull-ups",
                                exerciseName: "Pull Ups",
                                exerciseCategory: .upperBody,
                                orderIndex: 1,
                                sets: [
                                    WorkoutSetModel(id: "s4", orderIndex: 0, reps: 10),
                                    WorkoutSetModel(id: "s5", orderIndex: 1, reps: 10)
                                ]
                            )
                        ],
                        createdBy: "user1",
                        isPublic: false,
                        tags: nil,
                        estimatedDuration: 60,
                        difficulty: .intermediate,
                        createdAt: .now,
                        updatedAt: .now
                    ),
                    assignedDate: .now
                )
            ),
            userId: "preview-user"
    )
}
