//
//  WorkoutSupersetConnector.swift
//  MyDayKit
//
//  Created by Findlay Wood on 18/11/2026.
//

import SwiftUI

extension View {

    /// Draws the line from this card's badge down to the next card's, across the gap between
    /// them, when the next exercise is in the same superset. A line rather than a box round the
    /// group: the cards keep their own chrome, matched-geometry heroes and tap targets unchanged,
    /// and the chain of badges is what says "do these together".
    ///
    /// `gap` must equal the spacing of the stack the cards sit in. `leading` is the badge's leading
    /// edge inside the card (its padding).
    func supersetConnector(_ entry: WorkoutSupersetLayout.Entry?, gap: CGFloat = 12, leading: CGFloat = 16) -> some View {
        overlay(alignment: .bottomLeading) {
            if entry?.position.continuesToNext == true {
                Capsule()
                    .fill(Color.darkColor)
                    .frame(width: 3, height: gap + 8)
                    .offset(x: leading + WorkoutSupersetBadge.size / 2 - 1.5, y: gap + 4)
                    .allowsHitTesting(false)
            }
        }
    }
}
