//
//  MyDayDayMarkerLegend.swift
//  MyDayKit
//
//  Created by Findlay Wood on 17/10/2026.
//

import SwiftUI

/// Says what the strip's dots mean, directly under the strip. Five-point dots cannot carry an
/// icon, so without this the colours are a code the user has to guess.
struct MyDayDayMarkerLegend: View {
    var body: some View {
        HStack(spacing: 14) {
            ForEach(MyDayDayMarkerKind.allCases, id: \.self) { kind in
                HStack(spacing: 5) {
                    Circle()
                        .fill(kind.color(onBrandSurface: false))
                        .frame(width: 6, height: 6)
                    Text(kind.title)
                        .font(.system(size: 11, weight: .medium))
                        .foregroundStyle(Color.secondary)
                }
            }
            Spacer()
        }
    }
}
