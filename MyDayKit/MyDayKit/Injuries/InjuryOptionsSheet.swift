//
//  InjuryOptionsSheet.swift
//  MyDayKit
//
//  Created by Findlay Wood on 10/11/2026.
//

import SwiftUI

/// An injury's `⋯`: "It's cleared up" and "Remove". Drawn as `SportCardOptionsSheet` is, row for
/// row.
///
/// **Clearing and removing are different things and say so.** Cleared is the injury's end —
/// it stays in the history the later charts draw. Remove is for one added by mistake, and is
/// the destructive row.
struct InjuryOptionsSheet: View {

    let title: String
    let onResolve: () -> Void
    let onRemove: () -> Void

    var body: some View {
        VStack(alignment: .leading, spacing: 0) {
            Text(title)
                .font(.system(size: 16, weight: .semibold))
                .foregroundColor(.primary)
                .padding(.horizontal, 20)
                .padding(.top, 20)
                .padding(.bottom, 16)

            Divider()

            row(icon: "checkmark.circle", title: "It's cleared up", color: .primary, action: onResolve)
            row(icon: "trash", title: "Remove — added by mistake", color: .red, action: onRemove)

            Spacer()
        }
    }

    private func row(icon: String, title: String, color: Color, action: @escaping () -> Void) -> some View {
        Button(action: action) {
            HStack(spacing: 14) {
                Image(systemName: icon)
                    .font(.system(size: 16, weight: .medium))
                    .foregroundColor(color == .primary ? Color.darkColor : color)
                    .frame(width: 28)
                Text(title)
                    .font(.system(size: 16, weight: .medium))
                    .foregroundColor(color)
                Spacer()
            }
            .padding(.horizontal, 20)
            .padding(.vertical, 16)
            .contentShape(Rectangle())
        }
        .buttonStyle(.plain)
    }
}

#Preview {
    InjuryOptionsSheet(title: "Left hamstring", onResolve: {}, onRemove: {})
        .presentationDetents([.height(210)])
}
