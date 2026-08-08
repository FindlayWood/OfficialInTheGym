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

    /// Skeleton rows shaped like the real ones — icon tile, title bar, subtitle
    /// bar — under the same "Your Library" heading, so the list appears to fill
    /// in rather than being replaced by a different layout. Grey slabs of a
    /// different height read as a separate screen that then swaps out.
    ///
    /// Local storage answers almost immediately, so in practice this is a brief
    /// flash on a cold start and is only really seen when the device is slow or
    /// the library is large. It is not the wait for the network — that happens
    /// behind an already-populated list.
    private var loadingView: some View {
        VStack(spacing: 10) {
            Text("Your Library")
                .font(.caption)
                .fontWeight(.semibold)
                .foregroundColor(.secondary)
                .textCase(.uppercase)
                .tracking(1.2)
                .frame(maxWidth: .infinity, alignment: .leading)
                .padding(.top, 8)

            ForEach(0..<5, id: \.self) { _ in
                skeletonRow
            }

            Spacer()
        }
        .padding(.horizontal, 20)
    }

    private var skeletonRow: some View {
        HStack(spacing: 14) {
            RoundedRectangle(cornerRadius: 10, style: .continuous)
                .fill(Color(.tertiarySystemBackground))
                .frame(width: 44, height: 44)

            VStack(alignment: .leading, spacing: 7) {
                RoundedRectangle(cornerRadius: 4, style: .continuous)
                    .fill(Color(.tertiarySystemBackground))
                    .frame(width: 120, height: 13)
                // Wider than the title bar: the subtitle carries the exercise
                // count *and* the created date.
                RoundedRectangle(cornerRadius: 4, style: .continuous)
                    .fill(Color(.tertiarySystemBackground))
                    .frame(width: 160, height: 11)
            }

            Spacer()
        }
        .padding(.horizontal, 16)
        .padding(.vertical, 12)
        .background(
            RoundedRectangle(cornerRadius: 14, style: .continuous)
                .fill(Color(.secondarySystemBackground))
        )
        .shimmering()
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
                            // Solid brand tile rather than a 12%-tinted one:
                            // at 44pt a wash of colour on a `secondarySystem`
                            // card barely registers, and the rows had nothing
                            // anchoring them. `dumbbell.fill` also reads far
                            // cleaner here than the busy figure glyph did.
                            RoundedRectangle(cornerRadius: 10, style: .continuous)
                                .fill(Color.darkColor)
                                .frame(width: 44, height: 44)
                                .overlay(
                                    Image(systemName: "dumbbell.fill")
                                        .font(.system(size: 18, weight: .semibold))
                                        .foregroundStyle(Color.white)
                                )

                            VStack(alignment: .leading, spacing: 3) {
                                Text(workout.title)
                                    .font(.system(size: 16, weight: .semibold))
                                    .foregroundColor(.primary)
                                Text(subtitle(for: workout))
                                    .font(.system(size: 13))
                                    .foregroundColor(.secondary)
                                    .lineLimit(1)
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

// MARK: - Row Subtitle

private extension MyDayWorkoutLibraryScreen {

    /// Exercise count plus when the template was created, in the same
    /// `"… · …"` shape `DailyWorkoutCard` uses.
    ///
    /// The date is the differentiator: the builder's name suggestions produce
    /// repeats — several "Saturday Upper" — and a list of identical titles over
    /// identical exercise counts is unpickable. `createdAt` is used rather than
    /// `updatedAt` because it is also what the library sorts by, so the dates
    /// read in order down the list; `updatedAt` would jump rows around relative
    /// to the sort as templates were edited.
    func subtitle(for workout: WorkoutTemplateModel) -> String {
        let count = workout.exercises.count
        let exercises = "\(count) \(count == 1 ? "exercise" : "exercises")"
        return "\(exercises) · \(Self.created(workout.createdAt))"
    }

    /// Today and yesterday carry the time, because several templates made in
    /// one sitting would otherwise all read "Today" and differentiate nothing —
    /// which is the exact case this was added for. Older ones only need the day.
    static func created(_ date: Date) -> String {
        let calendar = Calendar.current
        if calendar.isDateInToday(date) {
            return "Today, \(timeFormatter.string(from: date))"
        }
        if calendar.isDateInYesterday(date) {
            return "Yesterday, \(timeFormatter.string(from: date))"
        }
        if calendar.isDate(date, equalTo: .now, toGranularity: .year) {
            return dayFormatter.string(from: date)
        }
        return dayAndYearFormatter.string(from: date)
    }

    static let timeFormatter: DateFormatter = {
        let formatter = DateFormatter()
        formatter.dateFormat = "HH:mm"
        return formatter
    }()

    static let dayFormatter: DateFormatter = {
        let formatter = DateFormatter()
        formatter.setLocalizedDateFormatFromTemplate("d MMM")
        return formatter
    }()

    static let dayAndYearFormatter: DateFormatter = {
        let formatter = DateFormatter()
        formatter.setLocalizedDateFormatFromTemplate("d MMM yyyy")
        return formatter
    }()
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
    // Deliberately three "Saturday Upper" entries: the repeated names the
    // builder's suggestions produce are what the created date is there to tell
    // apart, so the preview has to show that case.
    let template: (String, String, Int, Date) -> WorkoutTemplateModel = { id, title, count, created in
        WorkoutTemplateModel(
            id: id,
            title: title,
            description: nil,
            exercises: (0..<count).map { index in
                WorkoutExerciseModel(
                    id: UUID().uuidString,
                    exerciseId: "",
                    exerciseName: "",
                    exerciseCategory: .upperBody,
                    orderIndex: index,
                    sets: []
                )
            },
            createdBy: "",
            isPublic: false,
            tags: nil,
            estimatedDuration: nil,
            difficulty: nil,
            createdAt: created,
            updatedAt: created
        )
    }

    let calendar = Calendar.current

    return NavigationStack {
        MyDayWorkoutLibraryScreen(
            manager: {
                let m = WorkoutLibraryManager(
                    local: PreviewWorkoutTemplateFetching(),
                    remote: PreviewWorkoutTemplateFetching()
                )
                m.state = .loaded([
                    template("1", "Saturday Upper", 6, .now),
                    template("2", "Saturday Upper", 5, calendar.date(byAdding: .hour, value: -3, to: .now)!),
                    template("3", "Saturday Upper", 4, calendar.date(byAdding: .day, value: -1, to: .now)!),
                    template("4", "Tuesday Lower", 5, calendar.date(byAdding: .day, value: -12, to: .now)!),
                    template("5", "Thursday Push", 4, calendar.date(byAdding: .year, value: -1, to: .now)!)
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
                let m = WorkoutLibraryManager(local: PreviewWorkoutTemplateFetching(), remote: PreviewWorkoutTemplateFetching())
                m.state = .empty
                return m
            }()
        )
    }
}

#Preview("Loading") {
    NavigationStack {
        MyDayWorkoutLibraryScreen(manager: WorkoutLibraryManager(local: PreviewWorkoutTemplateFetching(), remote: PreviewWorkoutTemplateFetching()))
    }
}
