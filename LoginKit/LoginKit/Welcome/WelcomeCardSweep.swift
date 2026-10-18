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
/// An angular gradient that is clear all the way round except for one short bright arc, rotated
/// by a `TimelineView` while the card is active. The timeline is paused otherwise, so an inactive
/// card costs nothing. It is drawn just outside the card's edge (`inset`), which is why the cards
/// need room on either side — see the horizontal padding inside `WelcomeView`'s scroll view.
struct WelcomeCardSweep: View {

    let isActive: Bool
    var cornerRadius: CGFloat = 16
    var inset: CGFloat = 2

    /// One lap. Slow enough to follow, fast enough to go round once or twice in a turn.
    private let lapDuration: TimeInterval = 1.8

    var body: some View {
        TimelineView(.animation(paused: !isActive)) { context in
            let progress = context.date.timeIntervalSinceReferenceDate
                .truncatingRemainder(dividingBy: lapDuration) / lapDuration

            RoundedRectangle(cornerRadius: cornerRadius + inset, style: .continuous)
                .strokeBorder(
                    AngularGradient(
                        stops: [
                            .init(color: .clear, location: 0),
                            .init(color: .clear, location: 0.62),
                            .init(color: Color.lightColor.opacity(0.6), location: 0.8),
                            .init(color: Color.darkColor, location: 0.92),
                            .init(color: .clear, location: 1)
                        ],
                        center: .center,
                        angle: .degrees(progress * 360)
                    ),
                    lineWidth: 2
                )
                .padding(-inset)
        }
        .opacity(isActive ? 1 : 0)
        .animation(.easeInOut(duration: 0.35), value: isActive)
        .allowsHitTesting(false)
    }
}

#Preview {
    RoundedRectangle(cornerRadius: 16)
        .fill(Color(UIColor.secondarySystemBackground))
        .frame(height: 92)
        .overlay { WelcomeCardSweep(isActive: true) }
        .padding(24)
}
