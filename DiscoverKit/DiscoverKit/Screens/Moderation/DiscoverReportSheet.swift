//
//  DiscoverReportSheet.swift
//  DiscoverKit
//
//  Created by Findlay Wood on 30/09/2026.
//

import SwiftUI

/// Reporting one thing: pick a reason, and it is filed. A fixed list rather
/// than a text box — see `DiscoverReportReason`.
///
/// The thing disappears for the reporter the moment the reason is tapped (the
/// store hides it optimistically); the sheet then says what happens next and
/// Done closes it. A failed report says so and leaves the reasons tappable.
struct DiscoverReportSheet: View {

    enum Phase: Equatable {
        case choosing
        case sending(DiscoverReportReason)
        case sent
        case failed
    }

    let target: DiscoverReportTarget
    @ObservedObject var moderation: DiscoverModerationStore
    var onFinished: () -> Void = {}

    @Environment(\.dismiss) private var dismiss
    @State private var phase: Phase = .choosing

    var body: some View {
        VStack(alignment: .leading, spacing: 0) {
            HStack(alignment: .top) {
                VStack(alignment: .leading, spacing: 3) {
                    Text(phase == .sent ? "Thanks for reporting" : "Report \(target.noun)")
                        .font(.system(size: 16, weight: .semibold))
                    Text(phase == .sent
                         ? "You won't see this \(target.noun) again. We'll review it."
                         : "Why are you reporting this?")
                        .font(.system(size: 13))
                        .foregroundStyle(.secondary)
                }
                Spacer()
                if phase == .sent {
                    Button("Done") {
                        dismiss()
                        onFinished()
                    }
                    .font(.system(size: 15, weight: .semibold))
                    .foregroundStyle(Color.darkColor)
                }
            }
            .padding(20)

            Divider()

            if phase != .sent {
                ScrollView {
                    VStack(spacing: 0) {
                        ForEach(DiscoverReportReason.allCases) { reason in
                            reasonRow(reason)
                            if reason != DiscoverReportReason.allCases.last {
                                Divider().padding(.leading, 20)
                            }
                        }
                        if phase == .failed {
                            Text("Couldn't send your report. Try again.")
                                .font(.system(size: 13))
                                .foregroundStyle(.secondary)
                                .padding(20)
                        }
                    }
                }
            }
            Spacer(minLength: 0)
        }
        .interactiveDismissDisabled(phase.isSending)
    }

    private func reasonRow(_ reason: DiscoverReportReason) -> some View {
        Button {
            Task {
                phase = .sending(reason)
                phase = await moderation.report(target, reason: reason) ? .sent : .failed
            }
        } label: {
            HStack {
                Text(reason.title)
                    .font(.system(size: 15))
                    .foregroundStyle(.primary)
                Spacer()
                if phase == .sending(reason) {
                    ProgressView()
                } else {
                    Image(systemName: "chevron.right")
                        .font(.system(size: 13, weight: .semibold))
                        .foregroundStyle(.tertiary)
                }
            }
            .padding(.horizontal, 20)
            .padding(.vertical, 15)
            .contentShape(Rectangle())
        }
        .buttonStyle(.plain)
        .disabled(phase.isSending)
    }
}

private extension DiscoverReportSheet.Phase {
    var isSending: Bool {
        if case .sending = self { return true }
        return false
    }
}
