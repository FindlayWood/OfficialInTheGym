//
//  WorkoutSessionNoticeBanner.swift
//  MyDayKit
//
//  Created by Findlay Wood on 18/10/2026.
//

import SwiftUI

/// A quiet strip under the session nav bar. The demo workout uses it for a
/// hint that changes as the user goes, over a line saying nothing is saved —
/// someone trying the app before signup should not have to discover the
/// gestures alone, nor wonder where their sets went.
///
/// A banner rather than coach marks: the set detail overlay already owns the
/// full-screen layer, and spotlight tours get tapped through unread.
struct WorkoutSessionNoticeBanner: View {

    let notice: WorkoutSessionNotice

    var body: some View {
        HStack(alignment: .top, spacing: 10) {
            Image(systemName: "lightbulb.fill")
                .font(.system(size: 13, weight: .semibold))
                .padding(.top, 1)

            VStack(alignment: .leading, spacing: 2) {
                Text(notice.text)
                    .font(.system(size: 14, weight: .semibold))
                    .fixedSize(horizontal: false, vertical: true)
                    .contentTransition(.opacity)
                if let detail = notice.detail {
                    Text(detail)
                        .font(.system(size: 12, weight: .medium))
                        .foregroundStyle(Color.secondary)
                }
            }

            Spacer(minLength: 0)
        }
        .foregroundStyle(Color.darkColor)
        .padding(.horizontal, 20)
        .padding(.vertical, 10)
        .frame(maxWidth: .infinity)
        .background(Color.darkColor.opacity(0.08))
        .animation(.easeInOut(duration: 0.2), value: notice)
    }
}

// MARK: - Preview

#Preview {
    WorkoutSessionNoticeBanner(
        notice: WorkoutSessionNotice(
            text: "Tap a set's circle to log it as written",
            detail: "Example workout · nothing you log is saved"
        )
    )
}
