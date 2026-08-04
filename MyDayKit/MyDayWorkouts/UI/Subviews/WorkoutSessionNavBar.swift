//
//  WorkoutSessionNavBar.swift
//  MyDayKit
//
//  Created by Findlay Wood on 04/08/2026.
//

import SwiftUI

/// Replaces the system navigation bar on the workout session screen so the set
/// detail overlay can cover the full screen. See
/// `WorkoutSessionHostingController` for why the real bar is hidden.
///
/// Back is a plain chevron with **no confirmation**: progress persists after
/// every set and the session resumes where it left off, so leaving genuinely
/// costs nothing and a warning would misrepresent the stakes. Cancelling the
/// workout is a separate, destructive action kept behind the overflow menu —
/// "cancel" rather than "end" because ending reads as finishing.
struct WorkoutSessionNavBar: View {

    let title: String
    let showsOptions: Bool
    var onBack: (() -> Void)?
    var onCancelWorkout: (() -> Void)?

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
                        Menu {
                            Button(role: .destructive) {
                                onCancelWorkout?()
                            } label: {
                                Label("Cancel Workout", systemImage: "xmark.circle")
                            }
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
        WorkoutSessionNavBar(title: "Monday Upper", showsOptions: true)
        Color.darkColor
    }
}
