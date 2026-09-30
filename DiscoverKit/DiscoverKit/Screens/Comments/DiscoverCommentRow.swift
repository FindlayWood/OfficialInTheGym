//
//  DiscoverCommentRow.swift
//  DiscoverKit
//
//  Created by Findlay Wood on 30/09/2026.
//

import SwiftUI

/// One comment or reply: avatar, name and age, the text, then like / reply /
/// delete.
///
/// A removed comment keeps its place — replies may hang off it — but shows
/// only "Comment removed": no author, no actions. Replies get no Reply button,
/// because replies go one level deep.
struct DiscoverCommentRow: View {

    let comment: DiscoverComment
    let author: DiscoverCommentsViewModel.AuthorName
    let isLiked: Bool
    let canRemove: Bool
    let onLike: () -> Void
    let onReply: (() -> Void)?
    let onRemove: () -> Void

    @State private var isConfirmingRemove = false

    var body: some View {
        if comment.isRemoved {
            removed
        } else {
            content
        }
    }

    private var removed: some View {
        HStack(spacing: 10) {
            DiscoverCommentAvatar(initial: nil, size: comment.isReply ? 26 : 32)
            Text("Comment removed")
                .font(.system(size: 14).italic())
                .foregroundStyle(.secondary)
            Spacer(minLength: 0)
        }
        .padding(.vertical, 10)
    }

    private var content: some View {
        HStack(alignment: .top, spacing: 10) {
            DiscoverCommentAvatar(initial: initial, size: comment.isReply ? 26 : 32)

            VStack(alignment: .leading, spacing: 4) {
                HStack(spacing: 4) {
                    Text(name)
                        .font(.system(size: 14, weight: .semibold))
                        .foregroundStyle(author == .deleted ? .secondary : .primary)
                        .redacted(reason: author == .loading ? .placeholder : [])
                    if let createdAt = comment.createdAt {
                        Text("· \(createdAt.discoverAge)")
                            .font(.system(size: 13))
                            .foregroundStyle(.secondary)
                    }
                }

                Text(comment.text)
                    .font(.system(size: 15))
                    .foregroundStyle(.primary)
                    .fixedSize(horizontal: false, vertical: true)

                HStack(spacing: 18) {
                    DiscoverLikeButton(isLiked: isLiked, count: comment.likeCount ?? 0, action: onLike)
                    if let onReply {
                        Button("Reply", action: onReply)
                            .font(.system(size: 13, weight: .semibold))
                            .foregroundStyle(.secondary)
                            .buttonStyle(.plain)
                    }
                    if canRemove {
                        Button("Delete") { isConfirmingRemove = true }
                            .font(.system(size: 13, weight: .semibold))
                            .foregroundStyle(.secondary)
                            .buttonStyle(.plain)
                    }
                }
                .padding(.top, 2)
            }
            Spacer(minLength: 0)
        }
        .padding(.vertical, 10)
        .confirmationDialog("Delete this comment?", isPresented: $isConfirmingRemove, titleVisibility: .visible) {
            Button("Delete", role: .destructive, action: onRemove)
        } message: {
            Text("Replies to it stay, under \"Comment removed\".")
        }
    }

    private var name: String {
        switch author {
        case .loading: return "Loading name"
        case .deleted: return "Deleted user"
        case .name(let name, _): return name
        }
    }

    private var initial: String? {
        if case .name(_, let initial) = author { return initial }
        return nil
    }
}
