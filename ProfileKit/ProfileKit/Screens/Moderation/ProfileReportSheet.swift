//
//  ProfileReportSheet.swift
//  ProfileKit
//
//  Created by Findlay Wood on 04/10/2026.
//

import SwiftUI

/// Reporting a profile: pick a reason, then Report. It is the same shape as
/// DISCOVER's report sheet, so reporting reads the same wherever it happens.
/// On success the sheet thanks the user and closes. It does not promise an
/// outcome, because three reporters or an admin decide that.
struct ProfileReportSheet: View {

    let displayName: String
    let onReport: (ProfileReportReason) async -> Bool
    @Environment(\.dismiss) private var dismiss

    @State private var reason: ProfileReportReason?
    @State private var isSending = false
    @State private var didFail = false
    @State private var didSend = false

    var body: some View {
        NavigationStack {
            ScrollView {
                VStack(alignment: .leading, spacing: 16) {
                    if didSend {
                        sent
                    } else {
                        Text("Why are you reporting \(displayName)? We'll review their name, bio and photo. They won't be told who reported them.")
                            .font(.system(size: 14))
                            .foregroundStyle(Color.secondary)
                            .fixedSize(horizontal: false, vertical: true)
                        reasons
                        if didFail {
                            ProfileErrorBanner(message: "Couldn't send the report. Check your connection and try again.")
                        }
                    }
                }
                .padding(16)
            }
            .navigationTitle("Report Profile")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button(didSend ? "Done" : "Cancel") { dismiss() }
                }
                if !didSend {
                    ToolbarItem(placement: .confirmationAction) {
                        if isSending {
                            ProgressView()
                        } else {
                            Button("Report") { Task { await send() } }
                                .fontWeight(.semibold)
                                .disabled(reason == nil)
                        }
                    }
                }
            }
            .tint(Color.darkColor)
        }
    }

    private var reasons: some View {
        VStack(spacing: 0) {
            ForEach(Array(ProfileReportReason.allCases.enumerated()), id: \.element) { index, option in
                Button {
                    reason = option
                } label: {
                    HStack {
                        Text(option.title)
                            .font(.system(size: 15, weight: .medium))
                            .foregroundStyle(Color.primary)
                        Spacer()
                        if reason == option {
                            Image(systemName: "checkmark")
                                .font(.system(size: 14, weight: .semibold))
                                .foregroundStyle(Color.darkColor)
                        }
                    }
                    .padding(.horizontal, 14)
                    .frame(minHeight: 48)
                    .contentShape(Rectangle())
                }
                .buttonStyle(.plain)
                if index < ProfileReportReason.allCases.count - 1 {
                    Divider().padding(.leading, 14)
                }
            }
        }
        .background(
            RoundedRectangle(cornerRadius: 16, style: .continuous)
                .fill(Color(.secondarySystemBackground))
        )
    }

    private var sent: some View {
        VStack(spacing: 10) {
            Image(systemName: "checkmark.circle.fill")
                .font(.system(size: 36))
                .foregroundStyle(Color.darkColor)
            Text("Thanks for letting us know")
                .font(.system(size: 17, weight: .semibold))
            Text("If you don't want to see them, you can also block them from their profile.")
                .font(.system(size: 14))
                .foregroundStyle(Color.secondary)
                .multilineTextAlignment(.center)
        }
        .frame(maxWidth: .infinity)
        .padding(.vertical, 32)
    }

    private func send() async {
        guard let reason else { return }
        isSending = true
        didFail = false
        let ok = await onReport(reason)
        isSending = false
        if ok { didSend = true } else { didFail = true }
    }
}
