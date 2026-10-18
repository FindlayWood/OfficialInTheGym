//
//  WelcomeCardSweep.swift
//  LoginKit
//
//  Created by Findlay Wood on 18/10/2026.
//

import SwiftUI

/// A flash of light running round the outside of the welcome card whose scene is playing — the
/// card the eye should be on. It replaced a static outline, which marked the card but did not
/// draw the eye to it.
///
/// **It moves along the edge at a steady speed.** The first version rotated an angular gradient,
/// which turns at a steady *angle*, and on a card three times wider than it is tall that sped up
/// at the ends and dawdled along the middles. This trims the card's own outline instead —
/// `trim(from:to:)` measures by length along the path — so the light covers equal distance in
/// equal time all the way round. The light is a few short trims at falling opacity, a bright head
/// and a fading tail, and wraps across the path's start in two pieces.
///
/// A `TimelineView` drives it while the card is active and is paused otherwise, so an inactive
/// card costs nothing. It is drawn just outside the card's edge (`inset`), which is why the cards
/// need room on either side — see the horizontal padding inside `WelcomeView`'s scroll view.
struct WelcomeCardSweep: View {

    let isActive: Bool
    var cornerRadius: CGFloat = 16
    var inset: CGFloat = 2

    /// One lap. Slow enough to follow, fast enough to go round once or twice in a turn.
    private let lapDuration: TimeInterval = 1.8

    /// The light, head first: each piece's share of the outline and its opacity.
    private let pieces: [(length: CGFloat, opacity: Double)] = [
        (0.04, 1.0), (0.04, 0.7), (0.05, 0.45), (0.06, 0.22), (0.07, 0.08)
    ]

    var body: some View {
        TimelineView(.animation(paused: !isActive)) { context in
            let head = CGFloat(
                context.date.timeIntervalSinceReferenceDate
                    .truncatingRemainder(dividingBy: lapDuration) / lapDuration
            )

            ZStack {
                ForEach(Array(segments(head: head).enumerated()), id: \.offset) { _, segment in
                    RoundedRectangle(cornerRadius: cornerRadius + inset, style: .continuous)
                        .trim(from: segment.from, to: segment.to)
                        .stroke(Color.darkColor.opacity(segment.opacity), style: StrokeStyle(lineWidth: 2, lineCap: .round))
                }
            }
            .padding(-inset)
        }
        .opacity(isActive ? 1 : 0)
        .animation(.easeInOut(duration: 0.35), value: isActive)
        .allowsHitTesting(false)
    }

    /// The pieces laid back from `head` along the outline, each split in two where it crosses the
    /// path's start, since a trim cannot run from 0.95 round to 0.05.
    private func segments(head: CGFloat) -> [(from: CGFloat, to: CGFloat, opacity: Double)] {
        var result: [(from: CGFloat, to: CGFloat, opacity: Double)] = []
        var end = head
        for piece in pieces {
            let start = end - piece.length
            if start >= 0 {
                result.append((start, end, piece.opacity))
            } else {
                if end > 0 { result.append((0, end, piece.opacity)) }
                result.append((1 + start, 1, piece.opacity))
            }
            end = start < 0 ? start + 1 : start
        }
        return result
    }
}

#Preview {
    RoundedRectangle(cornerRadius: 16)
        .fill(Color(UIColor.secondarySystemBackground))
        .frame(height: 92)
        .overlay { WelcomeCardSweep(isActive: true) }
        .padding(24)
}
