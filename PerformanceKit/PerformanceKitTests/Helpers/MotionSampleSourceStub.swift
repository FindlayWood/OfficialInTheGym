//
//  MotionSampleSourceStub.swift
//  PerformanceKitTests
//
//  Created by Findlay Wood on 10/10/2026.
//
import Foundation
@testable import PerformanceKit

/// Motion sensors that hand over a fixed run of samples the moment they
/// start, and say whether they exist. Never asserts.
@MainActor
final class MotionSampleSourceStub: MotionSampleSource {

    var isAvailable: Bool
    var samples: [MotionSample]
    private(set) var startCount = 0
    private(set) var stopCount = 0

    init(isAvailable: Bool = true, samples: [MotionSample] = []) {
        self.isAvailable = isAvailable
        self.samples = samples
    }

    func start(_ onSample: @escaping (MotionSample) -> Void) {
        startCount += 1
        samples.forEach(onSample)
    }

    func stop() {
        stopCount += 1
    }
}
