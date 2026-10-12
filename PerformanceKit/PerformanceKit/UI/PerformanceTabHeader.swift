//
//  PerformanceTabHeader.swift
//  PerformanceKit
//
//  Created by Findlay Wood on 12/10/2026.
//
import SwiftUI

/// The PERFORMANCE tab's title bar, drawn the way every other tab draws its own — MyDay, Discover
/// and Stats each hide the system bar and put a 28pt bold `darkColor` title on a `systemBackground`
/// band. PERFORMANCE alone kept the system large title, so switching to it changed the frame of the
/// app. **Keep it in step with those headers** (`DiscoverHomeScreen.header` is the closest: same
/// paddings, same 44pt trailing button).
///
/// `onDismiss` is set only when PERFORMANCE is presented rather than a tab — a coach's athlete page
/// and the legacy callers — and draws the close button that used to be the system bar's "Dismiss".
struct PerformanceTabHeader: View {

    let title: String
    var onDismiss: (() -> Void)?

    var body: some View {
        HStack {
            Text(title)
                .font(.system(size: 28, weight: .bold))
                .foregroundStyle(Color.darkColor)
            Spacer()
            if let onDismiss {
                Button(action: onDismiss) {
                    Image(systemName: "xmark")
                        .font(.system(size: 18, weight: .semibold))
                        .foregroundStyle(Color.darkColor)
                        .frame(width: 44, height: 44)
                }
                .accessibilityLabel("Close")
            }
        }
        .padding(.leading, 16)
        .padding(.trailing, 6)
        .frame(minHeight: 44)
        .padding(.vertical, 6)
        .background {
            Color(.systemBackground).ignoresSafeArea()
        }
    }
}
