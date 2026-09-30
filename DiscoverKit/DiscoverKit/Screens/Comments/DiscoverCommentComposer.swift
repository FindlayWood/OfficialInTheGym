//
//  DiscoverCommentComposer.swift
//  DiscoverKit
//
//  Created by Findlay Wood on 30/09/2026.
//

import SwiftUI

/// The bar at the bottom of the comments screen: a growing text field and a
/// send button, with a "Replying to" chip above it while a reply is being
/// written. Send is `darkColor` when the text can be posted and the gated
/// `tertiarySystemFill` otherwise — the same disabled look as every other
/// gated button in the app.
struct DiscoverCommentComposer: View {

    @ObservedObject var viewModel: DiscoverCommentsViewModel
    @FocusState private var isFocused: Bool

    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            if let parent = viewModel.replyingTo {
                HStack(spacing: 6) {
                    Text("Replying to \(replyName(for: parent))")
                        .font(.system(size: 13, weight: .medium))
                        .foregroundStyle(.secondary)
                    Button {
                        viewModel.replyingTo = nil
                    } label: {
                        Image(systemName: "xmark.circle.fill")
                            .foregroundStyle(.tertiary)
                    }
                    .buttonStyle(.plain)
                }
            }

            HStack(alignment: .bottom, spacing: 10) {
                TextField(viewModel.replyingTo == nil ? "Add a comment" : "Add a reply", text: $viewModel.draft, axis: .vertical)
                    .lineLimit(1...5)
                    .font(.system(size: 15))
                    .focused($isFocused)
                    .padding(.horizontal, 14)
                    .padding(.vertical, 10)
                    .background(Color(.tertiarySystemBackground), in: RoundedRectangle(cornerRadius: 20))

                Button {
                    Task { await viewModel.post() }
                } label: {
                    Group {
                        if viewModel.isPosting {
                            ProgressView().tint(.white)
                        } else {
                            Image(systemName: "arrow.up")
                                .font(.system(size: 16, weight: .bold))
                        }
                    }
                    .foregroundStyle(viewModel.canPost || viewModel.isPosting ? .white : Color.secondary)
                    .frame(width: 40, height: 40)
                    .background(
                        Circle().fill(viewModel.canPost || viewModel.isPosting ? Color.darkColor : Color(UIColor.tertiarySystemFill))
                    )
                }
                .buttonStyle(.plain)
                .disabled(!viewModel.canPost)
                .animation(.easeInOut(duration: 0.15), value: viewModel.canPost)
            }

            if viewModel.draft.count > DiscoverCommentsViewModel.maxLength {
                Text("\(viewModel.draft.count) / \(DiscoverCommentsViewModel.maxLength)")
                    .font(.system(size: 12))
                    .foregroundStyle(.secondary)
            }
        }
        .padding(.horizontal, 16)
        .padding(.vertical, 10)
        .background(Color(.secondarySystemBackground))
        .onChange(of: viewModel.replyingTo) { _, parent in
            if parent != nil { isFocused = true }
        }
    }

    private func replyName(for comment: DiscoverComment) -> String {
        if case .name(let name, _) = viewModel.author(of: comment) { return name }
        return "comment"
    }
}
