//
//  MyDayGettingStartedScreen.swift
//  MyDayKit
//
//  Created by Findlay Wood on 19/10/2026.
//

import SwiftUI

/// Getting Started, opened from the welcome card, the joined row, or Settings.
///
/// **A list the user reads in any order, never a pager they are walked
/// through.** Nothing here is shown unasked — it is behind a button — which is
/// what lets it exist beside the rule that the app has no step that only
/// tells. Three parts:
/// - **Your day** — check in, train, rate, in the colours the timeline and
///   date-strip markers use, so the page and this sheet read as one thing.
/// - **Try it** — rows that *do* the thing rather than describe it. The
///   practice workout is the welcome screen's `MyDayDemoWorkoutRouter`, which
///   saves nothing by construction, so a new user can run a session without
///   putting a fake one in their history.
/// - **Good to know** — only what the screen cannot show by looking at it,
///   chiefly the set pill's circle, which nothing marks as a separate button.
///
/// It sells nothing: pro has its own paywall and locked screens.
struct MyDayGettingStartedScreen: View {
    var onClose: () -> Void
    var onPracticeWorkout: () -> Void
    var onLogExercise: () -> Void
    var onBuildWorkout: () -> Void

    var body: some View {
        VStack(spacing: 0) {
            header

            ScrollView(showsIndicators: false) {
                VStack(alignment: .leading, spacing: 24) {
                    section("Your day") {
                        MyDayGettingStartedInfoRow(
                            icon: "heart.text.square.fill",
                            tint: .matteGreen,
                            title: "Check in",
                            detail: "A few quick questions on how you're feeling, before you train."
                        )
                        MyDayGettingStartedInfoRow(
                            icon: "dumbbell.fill",
                            tint: .darkColor,
                            title: "Train",
                            detail: "Log an exercise on its own, or add a workout and run it set by set."
                        )
                        MyDayGettingStartedInfoRow(
                            icon: "gauge.with.dots.needle.67percent",
                            tint: .matteAmber,
                            title: "Rate it",
                            detail: "Once you've trained, say how hard the day was out of 10.",
                            showsDivider: false
                        )
                    }

                    section("Try it") {
                        MyDayGettingStartedActionRow(
                            icon: "play.fill",
                            title: "Practice workout",
                            detail: "Three exercises on the real session screen. Nothing is saved.",
                            action: onPracticeWorkout
                        )
                        MyDayGettingStartedActionRow(
                            icon: "plus",
                            title: "Log an exercise",
                            detail: "Pick an exercise and record a set.",
                            action: onLogExercise
                        )
                        MyDayGettingStartedActionRow(
                            icon: "square.stack.3d.up.fill",
                            title: "Build a workout",
                            detail: "Save it to your library and add it to any day.",
                            showsDivider: false,
                            action: onBuildWorkout
                        )
                    }

                    section("Good to know") {
                        MyDayGettingStartedInfoRow(
                            icon: "checkmark.circle.fill",
                            tint: .darkColor,
                            title: "Tap a set's circle to log it as written",
                            detail: "Tap anywhere else on the set to change what you did."
                        )
                        MyDayGettingStartedInfoRow(
                            icon: "calendar",
                            tint: .darkColor,
                            title: "Look back at any day",
                            detail: "Tap the date under MyDay to see the last month.",
                            showsDivider: false
                        )
                    }
                }
                .padding(16)
            }
        }
        .background(Color(UIColor.systemGroupedBackground).ignoresSafeArea())
    }

    // MARK: - Header

    private var header: some View {
        HStack {
            Text("Getting started")
                .font(.system(size: 20, weight: .bold))
                .foregroundStyle(Color.primary)
            Spacer()
            Button(action: onClose) {
                Image(systemName: "xmark")
                    .font(.system(size: 13, weight: .bold))
                    .foregroundStyle(Color.secondary)
                    .frame(width: 36, height: 36)
                    .background(Color(UIColor.tertiarySystemFill))
                    .clipShape(Circle())
            }
            .accessibilityLabel("Close")
        }
        .padding(.horizontal, 16)
        .padding(.top, 20)
        .padding(.bottom, 8)
    }

    // MARK: - Section

    private func section<Content: View>(_ title: String, @ViewBuilder content: () -> Content) -> some View {
        VStack(alignment: .leading, spacing: 8) {
            Text(title)
                .font(.caption)
                .fontWeight(.semibold)
                .foregroundStyle(Color.secondary)
                .textCase(.uppercase)
                .tracking(1.2)
                .padding(.leading, 4)

            VStack(spacing: 0) {
                content()
            }
            .padding(.horizontal, 14)
            .padding(.vertical, 2)
            .background(Color(UIColor.secondarySystemGroupedBackground))
            .clipShape(RoundedRectangle(cornerRadius: 16, style: .continuous))
        }
    }
}

#Preview {
    MyDayGettingStartedScreen(onClose: {}, onPracticeWorkout: {}, onLogExercise: {}, onBuildWorkout: {})
}
