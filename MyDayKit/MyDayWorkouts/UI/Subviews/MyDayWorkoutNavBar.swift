//
//  MyDayWorkoutNavBar.swift
//  MyDayKit
//
//  Created by Findlay Wood on 04/08/2026.
//

import SwiftUI

/// Replaces the system navigation bar on the workout screens that present the
/// set detail overlay — the session screen and the template detail screen — so
/// the overlay can cover the full screen. See `NavBarHidingHostingController`
/// for why the real bar has to go.
///
/// Back is a plain chevron with **no confirmation** on either screen: session
/// progress persists after every set and resumes where it left off, and the
/// template screen is read-only, so leaving genuinely costs nothing and a
/// warning would misrepresent the stakes. Cancelling a workout is the separate
/// destructive action, kept behind the overflow menu — "cancel" rather than
/// "end" because ending reads as finishing.
///
/// The bar raises intent only. Both the menu and its confirmation are drawn by
/// the session screen as `WorkoutSessionDialogOverlay`; see that file for why
/// the system `Menu` and `confirmationDialog` were dropped.
struct MyDayWorkoutNavBar: View {

    let title: String

    /// The template screen passes `false` — it has nothing behind a `⋯`, and
    /// the bar then draws a matching blank so the title stays centred.
    var showsOptions: Bool = false
    var onBack: (() -> Void)?

    /// Opens `WorkoutSessionDialogOverlay` in its `.options` state. The bar
    /// deliberately does not own a `Menu`: the menu is drawn as a custom card
    /// by the screen, so it can dim over this bar and share a backdrop with the
    /// confirmation that follows it.
    var onOptions: (() -> Void)?

    var body: some View {
        VStack(spacing: 0) {
            ZStack {
                Text(title)
                    .font(.system(size: 17, weight: .semibold))
                    .foregroundStyle(Color.primary)
                    .lineLimit(1)
                    .minimumScaleFactor(0.8)
                    .padding(.horizontal, 56)

                HStack(spacing: 0) {
                    Button {
                        onBack?()
                    } label: {
                        Image(systemName: "chevron.left")
                            .font(.system(size: 17, weight: .semibold))
                            .foregroundStyle(Color.darkColor)
                            .frame(width: 44, height: 44)
                            .contentShape(Rectangle())
                    }

                    Spacer()

                    if showsOptions {
                        Button {
                            onOptions?()
                        } label: {
                            Image(systemName: "ellipsis")
                                .font(.system(size: 17, weight: .semibold))
                                .foregroundStyle(Color.darkColor)
                                .frame(width: 44, height: 44)
                                .contentShape(Rectangle())
                        }
                    } else {
                        Color.clear
                            .frame(width: 44, height: 44)
                    }
                }
            }
            .frame(height: 44)
            .padding(.horizontal, 4)

            Divider()
        }
        .background(Color.white.ignoresSafeArea(edges: .top))
    }
}

// MARK: - Preview

#Preview {
    VStack(spacing: 0) {
        MyDayWorkoutNavBar(title: "Monday Upper", showsOptions: true)
        Color.darkColor
    }
}
