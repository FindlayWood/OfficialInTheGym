//
//  SetRowTrailingSpace.swift
//  MyDayKit
//
//  Created by Findlay Wood on 18/11/2026.
//

import SwiftUI

/// Blank space at the end of a horizontal row of set pills, wide enough that the **last** pill can
/// scroll to the middle of the row. Without it the row ends at the last pill, so the set just
/// logged — usually the last one — stopped short of the centre the scroll asked for.
///
/// Sized off the row's own width (`containerRelativeFrame`), so it is right on every phone:
/// half the row, less half a pill, less the row's trailing padding and the stack spacing before
/// this view. **The defaults match the set rows**: 72pt pills, 16pt padding, 8pt spacing.
struct SetRowTrailingSpace: View {

    var pillWidth: CGFloat = 72
    var trailingPadding: CGFloat = 16
    var spacing: CGFloat = 8

    var body: some View {
        Color.clear
            .frame(height: 1)
            .containerRelativeFrame(.horizontal) { width, _ in
                max(0, width / 2 - pillWidth / 2 - trailingPadding - spacing)
            }
            .accessibilityHidden(true)
    }
}
