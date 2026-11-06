//
//  SportCardOptionsSheet.swift
//  MyDayKit
//
//  Created by Findlay Wood on 05/11/2026.
//

import SwiftUI

/// The sport card's `⋯`: the session's name and "Remove from Today". Drawn as
/// `WorkoutCardOptionsSheet` is, row for row — keep the two in step.
struct SportCardOptionsSheet: View {

    let title: String
    var onRemove: (() -> Void)?

    var body: some View {
        VStack(alignment: .leading, spacing: 0) {
            Text(title)
                .font(.system(size: 16, weight: .semibold))
                .foregroundColor(.primary)
                .padding(.horizontal, 20)
                .padding(.top, 20)
                .padding(.bottom, 16)

            Divider()

            Button {
                onRemove?()
            } label: {
                HStack(spacing: 14) {
                    Image(systemName: "trash")
                        .font(.system(size: 16, weight: .medium))
                        .foregroundColor(.red)
                        .frame(width: 28)
                    Text("Remove from Today")
                        .font(.system(size: 16, weight: .medium))
                        .foregroundColor(.red)
                    Spacer()
                }
                .padding(.horizontal, 20)
                .padding(.vertical, 16)
                .contentShape(Rectangle())
            }
            .buttonStyle(.plain)

            Spacer()
        }
    }
}

#Preview {
    SportCardOptionsSheet(title: "Basketball")
        .presentationDetents([.height(150)])
}
