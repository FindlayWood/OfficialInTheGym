//
//  MyDayTimelineNode.swift
//  MyDayKit
//
//  Created by Findlay Wood on 18/10/2026.
//

import SwiftUI

/// The dot beside a step on the MyDay timeline. Drawn on the page (`pageColor`), so a step's
/// colour comes from `MyDayDayMarkerKind.color(onBrandSurface: true)` — exercise is white there,
/// since a `darkColor` node would vanish into the navy page.
struct MyDayTimelineNode: View {
    let kind: MyDayDayMarkerKind
    let state: MyDayTimelineNodeState

    static let size: CGFloat = 12

    var body: some View {
        let color = kind.color(onBrandSurface: true)
        ZStack {
            switch state {
            case .done:
                Circle().fill(color)
            case .pending:
                Circle().strokeBorder(color, lineWidth: 1.5)
            case .unavailable:
                Circle().strokeBorder(color, lineWidth: 1.5).opacity(0.5)
            case .missing:
                Circle().fill(Color.white.opacity(0.25))
            }
        }
        .frame(width: Self.size, height: Self.size)
        .animation(.easeInOut(duration: 0.2), value: state)
    }
}
