//
//  WorkoutSessionDialogOverlay.swift
//  MyDayKit
//
//  Created by Findlay Wood on 08/08/2026.
//

import SwiftUI

/// The session screen's `⋯` menu and its cancel confirmation, drawn as a custom
/// centred card rather than a system `Menu` and `confirmationDialog`.
///
/// The system controls were replaced because both fought the screen they sat
/// on. A `Menu` anchors itself to the bar button and brings system chrome that
/// reads as a different app from the rest of the session; a
/// `confirmationDialog` slides up from the bottom edge — exactly where
/// `WorkoutSessionFinishBar` sits — so the destructive action landed under the
/// thumb in the same place as "Finish Workout".
///
/// Presented from `.overlay { }` on the screen for the same reason the set
/// detail overlay is: the session screen hides the system navigation bar
/// (`WorkoutSessionHostingController`), and only an overlay can dim over the
/// custom bar drawn in its place.
struct WorkoutSessionDialogOverlay: View {

    let dialog: WorkoutSessionDialog

    /// The menu's destructive row — steps to `.confirmCancel` rather than
    /// cancelling, so the discard is never one tap away.
    var onCancelWorkoutTapped: (() -> Void)?

    /// Confirmed. Calls through to `cancelSession()`.
    var onConfirmCancel: (() -> Void)?

    var onDismiss: (() -> Void)?

    var body: some View {
        ZStack {
            Color.black
                .opacity(0.6)
                .ignoresSafeArea()
                .transition(.opacity)
                .onTapGesture { onDismiss?() }

            card
                .frame(maxWidth: 320)
                .padding(24)
                .transition(.scale(scale: 0.92).combined(with: .opacity))
        }
    }

    // MARK: - Card

    private var card: some View {
        VStack(spacing: 0) {
            switch dialog {
            case .options:       optionsContent
            case .confirmCancel: confirmContent
            }
        }
        .background(Color.white)
        .clipShape(RoundedRectangle(cornerRadius: 20, style: .continuous))
        .shadow(color: Color.black.opacity(0.25), radius: 24, x: 0, y: 10)
    }

    // MARK: - Options

    private var optionsContent: some View {
        VStack(spacing: 0) {
            Text("WORKOUT OPTIONS")
                .font(.system(size: 10, weight: .semibold))
                .foregroundStyle(Color.secondary)
                .tracking(1.2)
                .padding(.vertical, 18)

            Divider()

            actionRow(
                title: "Cancel Workout",
                icon: "xmark.circle",
                tint: Color.red,
                action: { onCancelWorkoutTapped?() }
            )

            Divider()

            actionRow(
                title: "Close",
                icon: nil,
                tint: Color.secondary,
                action: { onDismiss?() }
            )
        }
    }

    private func actionRow(
        title: String,
        icon: String?,
        tint: Color,
        action: @escaping () -> Void
    ) -> some View {
        Button(action: action) {
            HStack(spacing: 10) {
                if let icon {
                    Image(systemName: icon)
                        .font(.system(size: 16, weight: .medium))
                }
                Text(title)
                    .font(.system(size: 16, weight: .semibold))
            }
            .foregroundStyle(tint)
            .frame(maxWidth: .infinity)
            .frame(height: 56)
            .contentShape(Rectangle())
        }
        .buttonStyle(.plain)
    }

    // MARK: - Confirm Cancel

    private var confirmContent: some View {
        VStack(spacing: 0) {
            VStack(spacing: 8) {
                Text("Cancel this workout?")
                    .font(.system(size: 18, weight: .bold))
                    .foregroundStyle(Color.primary)

                // `cancelSession()` genuinely discards everything, so the copy
                // has to say so — this is the one place in the flow where
                // leaving does cost the user something.
                Text("This will remove all logged sets and reset the workout. It stays on your day, so you can start it again.")
                    .font(.system(size: 14))
                    .foregroundStyle(Color.secondary)
                    .fixedSize(horizontal: false, vertical: true)
            }
            .multilineTextAlignment(.center)
            .padding(.horizontal, 20)
            .padding(.top, 24)
            .padding(.bottom, 20)

            VStack(spacing: 10) {
                // Destructive first because it is what the user came here for,
                // but tinted rather than filled — "Keep Going" is the solid
                // button, so the safe choice is the one the eye lands on.
                Button {
                    onConfirmCancel?()
                } label: {
                    Text("Cancel Workout")
                        .font(.system(size: 16, weight: .semibold))
                        .foregroundStyle(Color.red)
                        .frame(maxWidth: .infinity)
                        .frame(height: 52)
                        .background(Color.red.opacity(0.1))
                        .clipShape(RoundedRectangle(cornerRadius: 14, style: .continuous))
                }
                .buttonStyle(.plain)

                Button {
                    onDismiss?()
                } label: {
                    Text("Keep Going")
                        .font(.system(size: 16, weight: .semibold))
                        .foregroundStyle(Color.white)
                        .frame(maxWidth: .infinity)
                        .frame(height: 52)
                        .background(Color.darkColor)
                        .clipShape(RoundedRectangle(cornerRadius: 14, style: .continuous))
                }
                .buttonStyle(.plain)
            }
            .padding(.horizontal, 20)
            .padding(.bottom, 20)
        }
    }
}

// MARK: - Preview

#Preview("Options") {
    ZStack {
        Color.darkColor.ignoresSafeArea()
        WorkoutSessionDialogOverlay(dialog: .options)
    }
}

#Preview("Confirm Cancel") {
    ZStack {
        Color.darkColor.ignoresSafeArea()
        WorkoutSessionDialogOverlay(dialog: .confirmCancel)
    }
}
