//
//  BalanceSway.swift
//  PerformanceKit
//
//  Created by Findlay Wood on 10/10/2026.
//
import Foundation

/// One reading from the motion sensors: gravity and the acceleration the body
/// added to it, both in g, in the phone's own axes.
struct MotionSample: Equatable, Sendable {
    let gravity: SIMD3<Double>
    let acceleration: SIMD3<Double>
}

/// Sway from a stand's motion samples: **the root mean square of the
/// horizontal acceleration**, in thousandths of a g (mg).
///
/// Horizontal is taken against gravity at each sample, not against the
/// phone's axes, so it does not matter exactly how the phone is held to the
/// chest. Vertical bounce is dropped; balance is the side-to-side and
/// front-to-back wobble. RMS rather than a mean, so a few big corrections count
/// for more than steady small ones, which is what losing balance looks like.
enum BalanceSway {

    static func milliG(from samples: [MotionSample]) -> Double {
        let horizontal = samples.compactMap { sample -> Double? in
            let length = (sample.gravity * sample.gravity).sum().squareRoot()
            guard length > 0 else { return nil }
            let down = sample.gravity / length
            let along = (sample.acceleration * down).sum()
            let sideways = sample.acceleration - down * along
            return (sideways * sideways).sum()
        }
        guard !horizontal.isEmpty else { return 0 }
        let meanSquare = horizontal.reduce(0, +) / Double(horizontal.count)
        return (meanSquare.squareRoot() * 1000).rounded(toPlaces: 1)
    }
}
