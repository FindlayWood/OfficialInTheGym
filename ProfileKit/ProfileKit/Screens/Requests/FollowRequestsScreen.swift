//
//  FollowRequestsScreen.swift
//  ProfileKit
//
//  Created by Findlay Wood on 04/10/2026.
//

import SwiftUI

/// The follow-requests inbox, pushed from the row on the profile that appears
/// while any are waiting. See `FollowRequestsViewModel`.
struct FollowRequestsScreen: View {

    @ObservedObject var viewModel: FollowRequestsViewModel
    let photoLoader: ProfilePhotoLoader
    var onOpenProfile: ((String) -> Void)?

    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 16) {
                switch viewModel.loadState {
                case .loading:
                    ProgressView()
                        .frame(maxWidth: .infinity)
                        .padding(.vertical, 40)
                case .failed:
                    ProfileLoadFailedCard(title: "Couldn't Load Requests") {
                        Task { await viewModel.load() }
                    }
                case .loaded:
                    if let message = viewModel.errorMessage {
                        ProfileErrorBanner(message: message)
                    }
                    if viewModel.rows.isEmpty {
                        Text("No requests waiting.")
                            .font(.system(size: 15))
                            .foregroundStyle(Color.secondary)
                            .frame(maxWidth: .infinity)
                            .padding(.vertical, 40)
                    } else {
                        list
                    }
                }
            }
            .padding(16)
        }
        .refreshable { await viewModel.load() }
        .background(Color(.systemBackground).ignoresSafeArea())
        .navigationTitle("Follow Requests")
        .navigationBarTitleDisplayMode(.inline)
        .task { await viewModel.load() }
    }

    private var list: some View {
        LazyVStack(spacing: 0) {
            ForEach(Array(viewModel.rows.enumerated()), id: \.element.id) { index, row in
                FollowRequestRow(
                    row: row,
                    photoLoader: photoLoader,
                    showsDivider: index < viewModel.rows.count - 1,
                    onApprove: { Task { await viewModel.approve(row) } },
                    onDecline: { Task { await viewModel.decline(row) } },
                    onOpenProfile: onOpenProfile.map { open in { open(row.userId) } }
                )
                .onAppear {
                    if row.id == viewModel.rows.last?.id {
                        Task { await viewModel.loadMore() }
                    }
                }
            }
            if viewModel.isLoadingMore {
                ProgressView().padding(.vertical, 12)
            }
        }
        .background(
            RoundedRectangle(cornerRadius: 16, style: .continuous)
                .fill(Color(.secondarySystemBackground))
        )
    }
}
