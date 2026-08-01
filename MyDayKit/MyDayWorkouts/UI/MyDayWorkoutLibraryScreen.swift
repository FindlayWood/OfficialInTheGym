//
//  MyDayWorkoutLibraryScreen.swift
//  MyDayKit
//
//  Created by Findlay Wood on 03/06/2026.
//

import SwiftUI

struct MyDayWorkoutLibraryScreen: View {

    @ObservedObject var manager: WorkoutLibraryManager

    var onWorkoutSelected: ((WorkoutTemplateModel) -> Void)?
    var onCreateNewTapped: (() -> Void)?

    var body: some View {
        ZStack(alignment: .bottom) {

            Group {
                switch manager.state {
                case .loading:
                    loadingView
                case .empty:
                    emptyView
                case .loaded(let workouts):
                    listView(workouts: workouts)
                case .failed(let message):
                    failedView(message: message)
                }
            }
            .frame(maxWidth: .infinity, maxHeight: .infinity)

            // MARK: - Create New Button
            Button {
                onCreateNewTapped?()
            } label: {
                HStack(spacing: 10) {
                    Image(systemName: "plus.circle.fill")
                        .font(.system(size: 18, weight: .semibold))
                    Text("Create New Workout")
                        .font(.system(size: 17, weight: .semibold))
                }
                .frame(maxWidth: .infinity)
                .padding(.vertical, 16)
                .background(
                    RoundedRectangle(cornerRadius: 16, style: .continuous)
                        .fill(Color.darkColor)
                        .shadow(color: Color.darkColor.opacity(0.35), radius: 12, x: 0, y: 6)
                )
                .foregroundColor(.white)
            }
            .padding(.horizontal, 20)
            .padding(.bottom, 24)
        }
        .navigationTitle("Select Workout")
        .navigationBarTitleDisplayMode(.large)
        .onAppear {
            manager.loadIfNeeded()
        }
    }

    // MARK: - Loading
    private var loadingView: some View {
        VStack(spacing: 16) {
            ForEach(0..<5, id: \.self) { _ in
                RoundedRectangle(cornerRadius: 14, style: .continuous)
                    .fill(Color(.secondarySystemBackground))
                    .frame(maxWidth: .infinity)
                    .frame(height: 68)
                    .redacted(reason: .placeholder)
                    .shimmering()
            }
            Spacer()
        }
        .padding(.horizontal, 20)
        .padding(.top, 8)
    }

    // MARK: - Empty State
    private var emptyView: some View {
        VStack(spacing: 16) {
            Spacer()
            Image(systemName: "tray")
                .font(.system(size: 44, weight: .light))
                .foregroundStyle(.tertiary)

            VStack(spacing: 4) {
                Text("No Saved Workouts")
                    .font(.system(size: 17, weight: .semibold))
                    .foregroundColor(.primary)
                Text("Workouts you create will appear here")
                    .font(.system(size: 14))
                    .foregroundColor(.secondary)
            }
            Spacer()
            Spacer()
        }
    }

    // MARK: - Failed State
    private func failedView(message: String) -> some View {
        VStack(spacing: 16) {
            Spacer()
            Image(systemName: "exclamationmark.triangle")
                .font(.system(size: 44, weight: .light))
                .foregroundStyle(.tertiary)

            VStack(spacing: 4) {
                Text("Couldn't Load Workouts")
                    .font(.system(size: 17, weight: .semibold))
                    .foregroundColor(.primary)
                Text(message)
                    .font(.system(size: 14))
                    .foregroundColor(.secondary)
                    .multilineTextAlignment(.center)
                    .padding(.horizontal, 32)
            }

            Button {
                manager.load()
            } label: {
                Text("Try Again")
                    .font(.system(size: 15, weight: .semibold))
                    .foregroundStyle(Color.darkColor)
                    .padding(.horizontal, 20)
                    .padding(.vertical, 10)
                    .background(Capsule().fill(Color.darkColor.opacity(0.12)))
            }

            Spacer()
            Spacer()
        }
    }

    // MARK: - List
    private func listView(workouts: [WorkoutTemplateModel]) -> some View {
        ScrollView {
            VStack(spacing: 10) {
                Text("Your Library")
                    .font(.caption)
                    .fontWeight(.semibold)
                    .foregroundColor(.secondary)
                    .textCase(.uppercase)
                    .tracking(1.2)
                    .frame(maxWidth: .infinity, alignment: .leading)
                    .padding(.top, 8)

                ForEach(workouts) { workout in
                    Button {
                        onWorkoutSelected?(workout)
                    } label: {
                        HStack(spacing: 14) {
                            RoundedRectangle(cornerRadius: 10, style: .continuous)
                                .fill(Color.accentColor.opacity(0.12))
                                .frame(width: 44, height: 44)
                                .overlay(
                                    Image(systemName: "figure.strengthtraining.traditional")
                                        .font(.system(size: 18, weight: .medium))
                                        .foregroundColor(.accentColor)
                                )

                            VStack(alignment: .leading, spacing: 3) {
                                Text(workout.title)
                                    .font(.system(size: 16, weight: .semibold))
                                    .foregroundColor(.primary)
                                Text("\(workout.exercises.count) \(workout.exercises.count == 1 ? "exercise" : "exercises")")
                                    .font(.system(size: 13))
                                    .foregroundColor(.secondary)
                            }

                            Spacer()

                            Image(systemName: "chevron.right")
                                .font(.system(size: 13, weight: .semibold))
                                .foregroundStyle(.tertiary)
                        }
                        .padding(.horizontal, 16)
                        .padding(.vertical, 12)
                        .background(
                            RoundedRectangle(cornerRadius: 14, style: .continuous)
                                .fill(Color(.secondarySystemBackground))
                        )
                    }
                }

                // Bottom padding so list clears the fixed button
                Color.clear.frame(height: 88)
            }
            .padding(.horizontal, 20)
        }
    }
}

// MARK: - Shimmer modifier
private struct ShimmeringModifier: ViewModifier {
    @State private var phase: CGFloat = -1

    func body(content: Content) -> some View {
        content
            .overlay(
                GeometryReader { geo in
                    LinearGradient(
                        gradient: Gradient(stops: [
                            .init(color: .clear, location: 0),
                            .init(color: Color.white.opacity(0.35), location: 0.4),
                            .init(color: Color.white.opacity(0.35), location: 0.6),
                            .init(color: .clear, location: 1),
                        ]),
                        startPoint: .init(x: phase, y: 0),
                        endPoint: .init(x: phase + 1, y: 0)
                    )
                    .frame(width: geo.size.width)
                    .clipShape(RoundedRectangle(cornerRadius: 14, style: .continuous))
                }
            )
            .onAppear {
                withAnimation(.linear(duration: 1.4).repeatForever(autoreverses: false)) {
                    phase = 1
                }
            }
    }
}

private extension View {
    func shimmering() -> some View {
        modifier(ShimmeringModifier())
    }
}

// MARK: - Preview

#Preview("Loaded") {
    NavigationStack {
        MyDayWorkoutLibraryScreen(
            manager: {
                let m = WorkoutLibraryManager(fetcher: PreviewWorkoutTemplateFetching())
                m.state = .loaded([
                    WorkoutTemplateModel(id: "1", title: "Monday Upper", description: nil, exercises: Array(repeating: WorkoutExerciseModel(id: UUID().uuidString, exerciseId: "", exerciseName: "", exerciseCategory: .upperBody, orderIndex: 0, sets: []), count: 6), createdBy: "", isPublic: false, tags: nil, estimatedDuration: nil, difficulty: nil, createdAt: .now, updatedAt: .now),
                    WorkoutTemplateModel(id: "2", title: "Tuesday Lower", description: nil, exercises: Array(repeating: WorkoutExerciseModel(id: UUID().uuidString, exerciseId: "", exerciseName: "", exerciseCategory: .upperBody, orderIndex: 0, sets: []), count: 5), createdBy: "", isPublic: false, tags: nil, estimatedDuration: nil, difficulty: nil, createdAt: .now, updatedAt: .now),
                    WorkoutTemplateModel(id: "3", title: "Thursday Push", description: nil, exercises: Array(repeating: WorkoutExerciseModel(id: UUID().uuidString, exerciseId: "", exerciseName: "", exerciseCategory: .upperBody, orderIndex: 0, sets: []), count: 4), createdBy: "", isPublic: false, tags: nil, estimatedDuration: nil, difficulty: nil, createdAt: .now, updatedAt: .now),
                ])
                return m
            }()
        )
    }
}

#Preview("Empty") {
    NavigationStack {
        MyDayWorkoutLibraryScreen(
            manager: {
                let m = WorkoutLibraryManager(fetcher: PreviewWorkoutTemplateFetching())
                m.state = .empty
                return m
            }()
        )
    }
}

#Preview("Loading") {
    NavigationStack {
        MyDayWorkoutLibraryScreen(manager: WorkoutLibraryManager(fetcher: PreviewWorkoutTemplateFetching()))
    }
}
