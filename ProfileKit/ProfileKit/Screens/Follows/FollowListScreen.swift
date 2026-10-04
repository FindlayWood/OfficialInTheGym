//
//  FollowListScreen.swift
//  ProfileKit
//
//  Created by Findlay Wood on 04/10/2026.
//
import SwiftUI

/// A followers or following list, pushed from the counts on the profile header.
/// See `FollowListViewModel`.
///
/// Removing a follower asks first. It is silent to them, and a mis-tap is not
/// undone by tapping again, as unfollowing is.
struct FollowListScreen: View {

    @ObservedObject var viewModel: FollowListViewModel
    let photoLoader: ProfilePhotoLoader

    @State private var confirmingRemoval: FollowListViewModel.Row?

    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 16) {
                switch viewModel.loadState {
                case .loading:
                    ProgressView()
                        .frame(maxWidth: .infinity)
                        .padding(.vertical, 40)
                case .failed:
                    ProfileLoadFailedCard(title: "Couldn't Load \(viewModel.kind.title)") {
                        Task { await viewModel.load() }
                    }
                case .loaded:
                    if let message = viewModel.errorMessage {
                        ProfileErrorBanner(message: message)
                    }
                    if viewModel.rows.isEmpty {
                        Text(viewModel.kind.emptyMessage)
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
        .navigationTitle(viewModel.kind.title)
        .navigationBarTitleDisplayMode(.inline)
        .task { await viewModel.load() }
        .alert(
            "Remove Follower?",
            isPresented: Binding(get: { confirmingRemoval != nil }, set: { if !$0 { confirmingRemoval = nil } }),
            presenting: confirmingRemoval
        ) { row in
            Button("Remove", role: .destructive) { Task { await viewModel.removeFollower(row) } }
            Button("Cancel", role: .cancel) {}
        } message: { row in
            Text("\(row.summary?.displayName ?? "They") won't be told they were removed.")
        }
    }

    private var list: some View {
        LazyVStack(spacing: 0) {
            ForEach(Array(viewModel.rows.enumerated()), id: \.element.id) { index, row in
                FollowListRow(
                    row: row,
                    kind: viewModel.kind,
                    photoLoader: photoLoader,
                    showsDivider: index < viewModel.rows.count - 1,
                    onToggleFollow: { Task { await viewModel.toggleFollow(row) } },
                    onRemove: viewModel.canRemoveFollowers ? { confirmingRemoval = row } : nil
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
