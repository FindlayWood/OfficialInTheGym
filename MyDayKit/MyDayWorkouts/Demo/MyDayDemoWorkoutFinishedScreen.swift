//
//  MyDayDemoWorkoutFinishedScreen.swift
//  MyDayKit
//
//  Created by Findlay Wood on 18/10/2026.
//

import SwiftUI

/// The end of the example workout, and the one place the demo asks for
/// anything.
///
/// "Complete Workout" used to pop straight back to the welcome screen, at the
/// moment someone is most interested, and left them to find Sign Up again.
/// This shows what they just did, says what an account would have done with
/// it, and puts **Create Account** under the thumb, going straight to signup.
/// "Back to start" is the quieter way out — the screen asks, it does not trap.
///
/// The copy claims only what an account does for everyone: the work is saved
/// and kept. It does not sell STATS here, which is pro.
struct MyDayDemoWorkoutFinishedScreen: View {

    let setsLogged: Int
    let durationSeconds: Int
    let exerciseCount: Int
    var onCreateAccount: (() -> Void)?
    var onBack: (() -> Void)?

    var body: some View {
        VStack(spacing: 0) {
            Spacer()

            Image(systemName: "checkmark.circle.fill")
                .font(.system(size: 64, weight: .semibold))
                .foregroundStyle(Color.darkColor)

            Text("Workout complete")
                .font(.system(size: 28, weight: .bold))
                .foregroundStyle(Color.primary)
                .padding(.top, 16)

            Text("That's how every workout works. With an account, each set you log is saved to your day and kept in your history.")
                .font(.system(size: 15))
                .foregroundStyle(Color.secondary)
                .multilineTextAlignment(.center)
                .fixedSize(horizontal: false, vertical: true)
                .padding(.top, 8)
                .padding(.horizontal, 12)

            statsCard
                .padding(.top, 28)

            Spacer()

            VStack(spacing: 10) {
                Button {
                    onCreateAccount?()
                } label: {
                    Text("Create Account")
                        .font(.system(size: 16, weight: .semibold))
                        .foregroundStyle(Color.white)
                        .frame(maxWidth: .infinity)
                        .frame(height: 52)
                        .background(Color.darkColor)
                        .clipShape(RoundedRectangle(cornerRadius: 14, style: .continuous))
                }

                Button {
                    onBack?()
                } label: {
                    Text("Back to start")
                        .font(.system(size: 16, weight: .semibold))
                        .foregroundStyle(Color.darkColor)
                        .frame(maxWidth: .infinity)
                        .frame(height: 52)
                        .background(Color.darkColor.opacity(0.12))
                        .clipShape(RoundedRectangle(cornerRadius: 14, style: .continuous))
                }
            }
        }
        .padding(.horizontal, 20)
        .padding(.bottom, 24)
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .background(Color(.systemBackground).ignoresSafeArea())
    }

    // MARK: - Stats

    private var statsCard: some View {
        HStack(spacing: 0) {
            stat(title: "SETS", value: "\(setsLogged)")
            Divider().frame(height: 32)
            stat(title: "TIME", value: formattedDuration)
            Divider().frame(height: 32)
            stat(title: "EXERCISES", value: "\(exerciseCount)")
        }
        .padding(.vertical, 16)
        .background(Color(UIColor.secondarySystemBackground))
        .clipShape(RoundedRectangle(cornerRadius: 16, style: .continuous))
    }

    private func stat(title: String, value: String) -> some View {
        VStack(spacing: 4) {
            Text(title)
                .font(.system(size: 10, weight: .semibold))
                .foregroundStyle(Color.secondary)
                .tracking(1.2)
            Text(value)
                .font(.system(size: 20, weight: .bold))
                .foregroundStyle(Color.primary)
        }
        .frame(maxWidth: .infinity)
    }

    private var formattedDuration: String {
        let m = durationSeconds / 60
        let s = durationSeconds % 60
        return String(format: "%d:%02d", m, s)
    }
}

// MARK: - Preview

#Preview {
    MyDayDemoWorkoutFinishedScreen(setsLogged: 7, durationSeconds: 312, exerciseCount: 3)
}
