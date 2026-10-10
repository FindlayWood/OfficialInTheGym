//
//  BalanceRecordingScreen.swift
//  PerformanceKit
//
//  Created by Findlay Wood on 10/10/2026.
//
import SwiftUI

/// One stand, full screen. Ready says which leg and how; the countdown and the
/// stand are a big number in a ring, readable at arm's length with the phone on
/// the chest; "Foot down" is the bottom button throughout, as large as a
/// button gets. The result offers Keep or Try again.
struct BalanceRecordingScreen: View {

    @ObservedObject var viewModel: BalanceRecordingViewModel
    let condition: BalanceCondition

    var body: some View {
        NavigationStack {
            VStack(spacing: 20) {
                Spacer()
                content
                Spacer()
            }
            .frame(maxWidth: .infinity)
            .padding(.horizontal, 32)
            .background(Color(.systemBackground).ignoresSafeArea())
            .performanceBottomBar { bottomBar }
            .navigationTitle("\(viewModel.side.title) leg")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .topBarLeading) {
                    Button("Cancel") { viewModel.cancel() }
                        .tint(Color.darkColor)
                }
            }
        }
        .interactiveDismissDisabled()
        // A stand leaves the screen untouched for over half a minute, past the
        // shortest auto-lock. Locking mid-stand would end the sampling.
        .onAppear { UIApplication.shared.isIdleTimerDisabled = true }
        .onDisappear { UIApplication.shared.isIdleTimerDisabled = false }
    }

    @ViewBuilder
    private var content: some View {
        switch viewModel.phase {
        case .ready:
            PerformanceIconTile(systemName: "figure.stand", size: 72)
            Text("Stand on your \(viewModel.side.title.lowercased()) leg")
                .font(.system(size: 22, weight: .bold))
                .multilineTextAlignment(.center)
            Text("Hold the phone flat against your chest with both hands. \(condition == .eyesClosed ? "Close your eyes when the countdown ends." : "Look straight ahead.") Hold still for \(Int(BalanceAttempt.targetDuration)) seconds; you'll hear when it starts and ends.")
                .font(.system(size: 15))
                .foregroundStyle(Color.secondary)
                .multilineTextAlignment(.center)

        case .countdown(let remaining):
            ring(progress: 0, label: "\(remaining)", caption: "Get ready")

        case .recording(let elapsed):
            let remaining = max(0, Int((BalanceAttempt.targetDuration - elapsed).rounded(.up)))
            ring(progress: elapsed / BalanceAttempt.targetDuration, label: "\(remaining)", caption: "Hold still")

        case .finished(let attempt):
            Text(attempt.sway.formatted(.number.precision(.fractionLength(1))))
                .font(.system(size: 56, weight: .bold))
                .foregroundStyle(Color.darkColor)
            + Text(" mg")
                .font(.system(size: 22, weight: .semibold))
                .foregroundStyle(Color.secondary)
            Text(attempt.completed
                 ? "Sway over \(Int(BalanceAttempt.targetDuration)) seconds. Lower is steadier."
                 : "Foot down at \(Int(attempt.duration)) seconds. It's kept, but only full stands count toward your best.")
                .font(.system(size: 15))
                .foregroundStyle(Color.secondary)
                .multilineTextAlignment(.center)

        case .unavailable:
            PerformanceIconTile(systemName: "gyroscope", size: 64)
            Text("No motion sensors available")
                .font(.system(size: 22, weight: .bold))
            Text("Balance is measured with the phone's motion sensors, and this device doesn't have them.")
                .font(.system(size: 15))
                .foregroundStyle(Color.secondary)
                .multilineTextAlignment(.center)
        }
    }

    @ViewBuilder
    private var bottomBar: some View {
        switch viewModel.phase {
        case .ready:
            PerformancePrimaryButton(title: "Start") { viewModel.start() }
        case .countdown, .recording:
            Button { viewModel.footDown() } label: {
                Text("Foot down")
                    .font(.system(size: 18, weight: .bold))
                    .foregroundStyle(Color.white)
                    .frame(maxWidth: .infinity)
                    .frame(height: 72)
                    .background(RoundedRectangle(cornerRadius: 14, style: .continuous).fill(Color.matteRed))
            }
            .buttonStyle(.plain)
        case .finished:
            VStack(spacing: 12) {
                PerformancePrimaryButton(title: "Keep") { viewModel.keep() }
                Button("Try again") { viewModel.retry() }
                    .font(.system(size: 15, weight: .semibold))
                    .tint(Color.darkColor)
            }
        case .unavailable:
            #if targetEnvironment(simulator)
            PerformancePrimaryButton(title: "Add a sample result (simulator)") { viewModel.addSample() }
            #else
            EmptyView()
            #endif
        }
    }

    private func ring(progress: Double, label: String, caption: String) -> some View {
        ZStack {
            Circle()
                .stroke(Color(.tertiarySystemFill), lineWidth: 14)
            Circle()
                .trim(from: 0, to: progress)
                .stroke(Color.darkColor, style: StrokeStyle(lineWidth: 14, lineCap: .round))
                .rotationEffect(.degrees(-90))
                .animation(.linear(duration: BalanceRecordingViewModel.tick), value: progress)
            VStack(spacing: 4) {
                Text(label)
                    .font(.system(size: 72, weight: .bold))
                    .monospacedDigit()
                Text(caption)
                    .font(.system(size: 15, weight: .semibold))
                    .foregroundStyle(Color.secondary)
            }
        }
        .frame(width: 240, height: 240)
    }
}
