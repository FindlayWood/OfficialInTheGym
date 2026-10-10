//
//  JumpCameraUnavailableScreen.swift
//  PerformanceKit
//
//  Created by Findlay Wood on 10/10/2026.
//
import SwiftUI

/// What opens in place of the jump camera when it cannot run: camera access
/// was turned off, or there is no camera at all.
///
/// **In the simulator only**, "Add a sample jump" hands the session a
/// plausible measured attempt for the test (`sample(for:)`), so the session,
/// saving and the dashboard can be exercised without a device. It is compiled
/// out of device builds.
struct JumpCameraUnavailableScreen: View {

    let availability: JumpCameraAvailability
    let kind: JumpTestKind
    let onClose: () -> Void
    let onSample: (JumpAttempt) -> Void

    @Environment(\.openURL) private var openURL

    var body: some View {
        NavigationStack {
            VStack(spacing: 16) {
                PerformanceIconTile(systemName: availability == .denied ? "video.slash.fill" : "camera.fill", size: 64)
                    .padding(.top, 48)
                Text(availability == .denied ? "Camera access is off" : "No camera available")
                    .font(.system(size: 22, weight: .bold))
                Text(availability == .denied
                     ? "Jumps are measured from video. Turn on camera access for INTHEGYM in Settings to record one."
                     : "Jumps are measured from video, and this device has no camera to record with.")
                    .font(.system(size: 15))
                    .foregroundStyle(Color.secondary)
                    .multilineTextAlignment(.center)
                Spacer()
            }
            .frame(maxWidth: .infinity)
            .padding(.horizontal, 32)
            .background(Color(.systemBackground).ignoresSafeArea())
            .performanceBottomBar {
                VStack(spacing: 12) {
                    if availability == .denied {
                        PerformancePrimaryButton(title: "Open Settings") {
                            if let url = URL(string: UIApplication.openSettingsURLString) { openURL(url) }
                        }
                    }
                    #if targetEnvironment(simulator)
                    PerformancePrimaryButton(title: "Add a sample jump (simulator)") {
                        onSample(Self.sample(for: kind))
                    }
                    #endif
                }
            }
            .toolbar {
                ToolbarItem(placement: .topBarLeading) {
                    Button("Close", action: onClose)
                        .tint(Color.darkColor)
                }
            }
        }
    }

    /// A plausible attempt measured the real way, from times through the same
    /// `JumpTiming` and `JumpPhysics` a recording uses, so a sample is
    /// indistinguishable from a jump downstream. Flight 0.50–0.62 s (about
    /// 31–47 cm); a drop jump adds a 0.18–0.26 s ground contact.
    static func sample(for kind: JumpTestKind) -> JumpAttempt {
        let flight = Double.random(in: 0.50...0.62)
        let contact = Double.random(in: 0.18...0.26)
        var times: [Double] = []
        var time = 1.0
        for (index, event) in kind.tagPlan.enumerated() {
            if index > 0 {
                time += kind.tagPlan[index - 1] == .takeOff && event == .landing ? flight : contact
            }
            times.append(time)
        }
        return JumpTiming(plan: kind.tagPlan, times: times).map(JumpAttempt.init(timing:))
            ?? JumpAttempt(height: JumpPhysics.heightCentimetres(flightTime: flight), flightTime: flight, contactTime: nil)
    }
}
