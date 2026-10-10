//
//  CoreMotionSampleSource.swift
//  PerformanceKit
//
//  Created by Findlay Wood on 10/10/2026.
//
import CoreMotion
import Foundation

/// The device's motion sensors at 50 Hz. Device motion separates gravity from
/// the acceleration the body adds, which is what sway is measured from. It
/// needs no permission. The simulator has no sensors (`isAvailable` false).
@MainActor
final class CoreMotionSampleSource: MotionSampleSource {

    private let manager = CMMotionManager()

    var isAvailable: Bool {
        manager.isDeviceMotionAvailable
    }

    func start(_ onSample: @escaping (MotionSample) -> Void) {
        guard manager.isDeviceMotionAvailable else { return }
        manager.deviceMotionUpdateInterval = 1.0 / 50.0
        manager.startDeviceMotionUpdates(to: .main) { motion, _ in
            guard let motion else { return }
            onSample(MotionSample(
                gravity: SIMD3(motion.gravity.x, motion.gravity.y, motion.gravity.z),
                acceleration: SIMD3(motion.userAcceleration.x, motion.userAcceleration.y, motion.userAcceleration.z)
            ))
        }
    }

    func stop() {
        manager.stopDeviceMotionUpdates()
    }
}
