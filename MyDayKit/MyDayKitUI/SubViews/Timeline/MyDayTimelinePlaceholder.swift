//
//  MyDayTimelinePlaceholder.swift
//  MyDayKit
//
//  Created by Findlay Wood on 18/10/2026.
//

import SwiftUI

/// A step that has not happened yet today, drawn where it will be once it has: a dashed outline
/// on the page with a title, one line saying what the step is, and its action. Dashed because it
/// is a slot, not a card — the real card replaces it.
///
/// Without an action it is the `.unavailable` step (rating a day with nothing trained on it),
/// and draws dimmed.
struct MyDayTimelinePlaceholder: View {
    let title: String
    let subtitle: String
    var actionTitle: String? = nil
    var actionTint: Color = .white
    var actionLabelColor: Color = .white
    var action: (() -> Void)? = nil

    var body: some View {
        HStack(spacing: 12) {
            VStack(alignment: .leading, spacing: 3) {
                Text(title)
                    .font(.system(size: 15, weight: .semibold))
                    .foregroundStyle(Color.white)
                Text(subtitle)
                    .font(.system(size: 13, weight: .regular))
                    .foregroundStyle(Color.white.opacity(0.7))
            }

            Spacer(minLength: 0)

            if let actionTitle, let action {
                Button(action: action) {
                    Text(actionTitle)
                        .font(.system(size: 13, weight: .semibold))
                        .foregroundStyle(actionLabelColor)
                        .padding(.horizontal, 14)
                        .padding(.vertical, 7)
                        .background(actionTint)
                        .clipShape(Capsule())
                }
                .buttonStyle(.plain)
            }
        }
        .padding(16)
        .overlay {
            RoundedRectangle(cornerRadius: 16)
                .strokeBorder(Color.white.opacity(0.45), style: StrokeStyle(lineWidth: 1, dash: [5, 4]))
        }
        .opacity(action == nil ? 0.5 : 1)
    }
}
