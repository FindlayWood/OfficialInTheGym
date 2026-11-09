//
//  ScheduleCard.swift
//  MyDayKit
//
//  Created by Findlay Wood on 08/11/2026.
//

import SwiftUI

/// One group of answers on `ScheduleSheet`, with an optional uppercase caption.
struct ScheduleCard<Content: View>: View {

    var title: String?
    @ViewBuilder let content: Content

    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            if let title {
                Text(title)
                    .font(.system(size: 12, weight: .semibold))
                    .foregroundStyle(Color.secondary)
                    .textCase(.uppercase)
                    .tracking(0.8)
            }
            content
        }
        .padding(16)
        .frame(maxWidth: .infinity, alignment: .leading)
        .background(
            RoundedRectangle(cornerRadius: 16, style: .continuous)
                .fill(Color(.secondarySystemBackground))
        )
    }
}
