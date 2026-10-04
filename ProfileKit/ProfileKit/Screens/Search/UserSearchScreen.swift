//
//  UserSearchScreen.swift
//  ProfileKit
//
//  Created by Findlay Wood on 04/10/2026.
//

import SwiftUI

/// User search, pushed from the magnifier on the profile's title bar. A field
/// in the MyDay input-well style, then results as follow-list-style rows that
/// open the person's profile.
struct UserSearchScreen: View {

    @ObservedObject var viewModel: UserSearchViewModel
    let photoLoader: ProfilePhotoLoader
    let onOpenProfile: (String) -> Void

    @FocusState private var isFocused: Bool

    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 16) {
                field
                content
            }
            .padding(16)
        }
        .scrollDismissesKeyboard(.interactively)
        .background(Color(.systemBackground).ignoresSafeArea())
        .navigationTitle("Find People")
        .navigationBarTitleDisplayMode(.inline)
        .onAppear { isFocused = true }
    }

    private var field: some View {
        HStack(spacing: 10) {
            Image(systemName: "magnifyingglass")
                .font(.system(size: 15, weight: .semibold))
                .foregroundStyle(Color.secondary)
            TextField("Search by name or @username", text: $viewModel.query)
                .font(.system(size: 16))
                .tint(Color.darkColor)
                .textInputAutocapitalization(.never)
                .autocorrectionDisabled()
                .submitLabel(.search)
                .focused($isFocused)
            if !viewModel.query.isEmpty {
                Button {
                    viewModel.query = ""
                } label: {
                    Image(systemName: "xmark.circle.fill")
                        .foregroundStyle(Color(.tertiaryLabel))
                }
                .accessibilityLabel("Clear search")
            }
        }
        .padding(.horizontal, 12)
        .frame(height: 44)
        .background(
            RoundedRectangle(cornerRadius: 12, style: .continuous)
                .fill(Color(.secondarySystemBackground))
        )
    }

    @ViewBuilder
    private var content: some View {
        switch viewModel.state {
        case .idle:
            message("Search for people to follow.")
        case .searching:
            ProgressView()
                .frame(maxWidth: .infinity)
                .padding(.vertical, 24)
        case .failed:
            message("Couldn't search. Check your connection and try again.")
        case .results(let results) where results.isEmpty:
            message("No one found.")
        case .results(let results):
            LazyVStack(spacing: 0) {
                ForEach(Array(results.enumerated()), id: \.element.userId) { index, summary in
                    UserSearchRow(
                        summary: summary,
                        photoLoader: photoLoader,
                        showsDivider: index < results.count - 1
                    ) {
                        onOpenProfile(summary.userId)
                    }
                }
            }
            .background(
                RoundedRectangle(cornerRadius: 16, style: .continuous)
                    .fill(Color(.secondarySystemBackground))
            )
        }
    }

    private func message(_ text: String) -> some View {
        Text(text)
            .font(.system(size: 15))
            .foregroundStyle(Color.secondary)
            .frame(maxWidth: .infinity)
            .padding(.vertical, 32)
    }
}
