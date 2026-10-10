//
//  BalanceCue.swift
//  PerformanceKit
//
//  Created by Findlay Wood on 10/10/2026.
//
import AudioToolbox
import UIKit

/// The sounds and taps a balance stand makes. **A stand with eyes closed
/// cannot be watched**, so the countdown, the start and the end are each heard
/// and felt, not only shown. The system sounds are the ones the jump camera
/// uses for its countdown and its end.
enum BalanceCue {
    case countdown
    case start
    case end

    @MainActor
    static func play(_ cue: BalanceCue) {
        switch cue {
        case .countdown:
            AudioServicesPlaySystemSound(SystemSoundID(1117))
            UIImpactFeedbackGenerator(style: .light).impactOccurred()
        case .start:
            AudioServicesPlaySystemSound(SystemSoundID(1113))
            UINotificationFeedbackGenerator().notificationOccurred(.success)
        case .end:
            AudioServicesPlaySystemSound(SystemSoundID(1118))
            UINotificationFeedbackGenerator().notificationOccurred(.success)
        }
    }
}
