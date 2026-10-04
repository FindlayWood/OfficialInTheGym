//
//  DiscoverCommentRow.swift
//  DiscoverKit
//
//  Created by Findlay Wood on 30/09/2026.
//

import SwiftUI

/// One comment or reply: avatar, name and age, the text, then like / reply /
/// delete, and a `⋯` for someone else's comment to report it or block its
/// author.
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
    /// Nil on your own comments — you cannot report or block yourself.
    var onReport: (() -> Void)?
    var onBlock: (() -> Void)?
    /// The author's avatar and name open their profile. Nil on a removed
    /// comment, a deleted author, or when profiles cannot be opened.
    var onOpenAuthor: (() -> Void)?

    @State private var isConfirmingRemove = false
    @State private var isShowingMore = false

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
            Button {
                onOpenAuthor?()
            } label: {
                DiscoverCommentAvatar(initial: initial, size: comment.isReply ? 26 : 32)
            }
            .buttonStyle(.plain)
            .disabled(onOpenAuthor == nil)

            VStack(alignment: .leading, spacing: 4) {
                HStack(spacing: 4) {
                    Button {
                        onOpenAuthor?()
                    } label: {
                        Text(name)
                            .font(.system(size: 14, weight: .semibold))
                            .foregroundStyle(author == .deleted ? .secondary : .primary)
                            .redacted(reason: author == .loading ? .placeholder : [])
                    }
                    .buttonStyle(.plain)
                    .disabled(onOpenAuthor == nil)
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
                    if onReport != nil || onBlock != nil {
                        Button {
                            isShowingMore = true
                        } label: {
                            Image(systemName: "ellipsis")
                                .font(.system(size: 13, weight: .semibold))
                                .foregroundStyle(.secondary)
                                .frame(width: 28, height: 20)
                                .contentShape(Rectangle())
                        }
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
        .confirmationDialog("", isPresented: $isShowingMore) {
            if let onReport {
                Button("Report comment", action: onReport)
            }
            if let onBlock {
                Button("Block \(name)", role: .destructive, action: onBlock)
            }
        } message: {
            if onBlock != nil {
                Text("Blocking hides their comments and clips from you. They won't be told.")
            }
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
