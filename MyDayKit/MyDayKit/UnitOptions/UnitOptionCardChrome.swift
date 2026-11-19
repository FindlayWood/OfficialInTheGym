//
//  UnitOptionCardChrome.swift
//  MyDayKit
//
//  Created by Findlay Wood on 19/11/2026.
//

import SwiftUI

extension View {

    /// The look of one option card — weight, distance, time, tempo, note — on the two units
    /// screens, the builder's (`MyDayWorkoutBuilderUnitsScreen`) and logging's (`MyDayUnitsHomeView`).
    /// **The one definition, so the twin screens cannot drift.**
    ///
    /// **Not added is a dashed outline with no fill**, MyDay's mark for a slot waiting to be
    /// filled (`MyDayTimelinePlaceholder`); **added is a solid card** with a `darkColor` border.
    /// Before, empty was a solid grey card and added the same card under a 6% tint, so the two
    /// read alike at a glance and only the small corner circle told them apart. The dash is a soft
    /// grey, not MyDay's white, because these screens sit on `systemBackground`, not the navy page.
    func unitOptionCardChrome(isAdded: Bool) -> some View {
        let shape = RoundedRectangle(cornerRadius: 14, style: .continuous)
        return self
            .background {
                if isAdded {
                    shape
                        .fill(Color(UIColor.secondarySystemBackground))
                        .overlay(shape.fill(Color.darkColor.opacity(0.08)))
                }
            }
            .overlay {
                if isAdded {
                    shape.strokeBorder(Color.darkColor.opacity(0.5), lineWidth: 1.5)
                } else {
                    shape.strokeBorder(
                        Color(UIColor.tertiaryLabel),
                        style: StrokeStyle(lineWidth: 1.2, dash: [5, 4])
                    )
                }
            }
            .clipShape(shape)
            // An empty card has no fill, and a Button only takes taps on what it draws.
            .contentShape(shape)
            .animation(.easeInOut(duration: 0.2), value: isAdded)
    }
}
