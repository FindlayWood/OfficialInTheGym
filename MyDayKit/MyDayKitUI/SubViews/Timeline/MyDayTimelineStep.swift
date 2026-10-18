//
//  MyDayTimelineStep.swift
//  MyDayKit
//
//  Created by Findlay Wood on 18/10/2026.
//

import SwiftUI

/// One step of the MyDay timeline — check in, train, rate — as a node on a rail with the step's
/// content beside it. The content is whatever the step already was: the check-in card, the
/// workout and exercise cards, the RPE card. **The timeline only adds the rail; it never
/// restyles what sits on it.**
///
/// The rail is drawn in the step's background so it is exactly as tall as the content, however
/// tall that grows — an exercise list, an expanding check-in. Each step draws the segment above
/// its node (unless first) and below it (unless last), so consecutive steps join into one line.
struct MyDayTimelineStep<Content: View>: View {
    let kind: MyDayDayMarkerKind
    let state: MyDayTimelineNodeState
    var isFirst: Bool = false
    var isLast: Bool = false
    /// Space under the content before the next step. Rows that carry their own padding and
    /// divider (`MyDayTimelineMissingRow`) pass 0, or the hairlines float between steps.
    var spacing: CGFloat = 12
    @ViewBuilder let content: Content

    /// Where the node sits from the top of the step: level with the first line of a card.
    private let nodeTop: CGFloat = 20
    private let railWidth: CGFloat = 14
    private let nodeGap: CGFloat = 3

    var body: some View {
        HStack(alignment: .top, spacing: 10) {
            MyDayTimelineNode(kind: kind, state: state)
                .frame(width: railWidth)
                .padding(.top, nodeTop)

            content
                .frame(maxWidth: .infinity, alignment: .leading)
                .padding(.bottom, isLast ? 0 : spacing)
        }
        .background(alignment: .topLeading) {
            rail.frame(width: railWidth)
        }
    }

    private var rail: some View {
        VStack(spacing: 0) {
            line
                .frame(height: max(nodeTop - nodeGap, 0))
                .opacity(isFirst ? 0 : 1)
            Color.clear
                .frame(height: MyDayTimelineNode.size + nodeGap * 2)
            line
                .opacity(isLast ? 0 : 1)
        }
    }

    private var line: some View {
        Rectangle()
            .fill(Color.white.opacity(0.22))
            .frame(width: 1.5)
    }
}
