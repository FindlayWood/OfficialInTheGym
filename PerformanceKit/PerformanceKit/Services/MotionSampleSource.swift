//
//  MotionSampleSource.swift
//  PerformanceKit
//
//  Created by Findlay Wood on 10/10/2026.
//
import Foundation

/// The motion sensors, as the balance test needs them: whether they exist, and
/// a stream of samples between `start` and `stop`. Behind a protocol so the
/// recording can be tested without a device; `CoreMotionSampleSource` is the
/// real one.
@MainActor
protocol MotionSampleSource: AnyObject {
    var isAvailable: Bool { get }
    func start(_ onSample: @escaping (MotionSample) -> Void)
    func stop()
}
