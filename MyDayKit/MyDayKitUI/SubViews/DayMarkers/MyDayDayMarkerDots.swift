//
//  MyDayDayMarkerDots.swift
//  MyDayKit
//
//  Created by Findlay Wood on 17/10/2026.
//

import SwiftUI

/// The row of dots under a date in the strip. Always three slots wide and always the same
/// height, marked or not, so a day gaining a marker never resizes its pill.
struct MyDayDayMarkerDots: View {
    let markers: MyDayDayMarkers
    let isSelected: Bool

    var body: some View {
        HStack(spacing: 3) {
            ForEach(MyDayDayMarkerKind.allCases, id: \.self) { kind in
                Circle()
                    .fill(kind.isPresent(in: markers) ? kind.color(onBrandSurface: isSelected) : Color.clear)
                    .frame(width: 5, height: 5)
            }
        }
        .animation(.easeInOut(duration: 0.15), value: markers)
        .accessibilityHidden(true)
    }
}
