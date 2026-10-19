//
//  MyDayGettingStartedInfoRow.swift
//  MyDayKit
//
//  Created by Findlay Wood on 19/10/2026.
//

import SwiftUI

/// A line of Getting Started that explains rather than opens: a tinted glyph,
/// a title and a sentence. Used for the three steps of a day — in the colours
/// the timeline and date-strip markers already give them — and for the tips.
struct MyDayGettingStartedInfoRow: View {
    let icon: String
    let tint: Color
    let title: String
    let detail: String
    var showsDivider: Bool = true

    var body: some View {
        HStack(alignment: .top, spacing: 12) {
            Image(systemName: icon)
                .font(.system(size: 14, weight: .semibold))
                .foregroundStyle(Color.white)
                .frame(width: 32, height: 32)
                .background(tint)
                .clipShape(RoundedRectangle(cornerRadius: 9, style: .continuous))

            VStack(alignment: .leading, spacing: 3) {
                Text(title)
                    .font(.system(size: 15, weight: .semibold))
                    .foregroundStyle(Color.primary)
                Text(detail)
                    .font(.system(size: 13))
                    .foregroundStyle(Color.secondary)
                    .fixedSize(horizontal: false, vertical: true)
            }
            Spacer(minLength: 0)
        }
        .padding(.vertical, 12)
        .overlay(alignment: .bottom) {
            if showsDivider {
                Divider().padding(.leading, 44)
            }
        }
    }
}
