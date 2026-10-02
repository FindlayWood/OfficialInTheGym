//
//  DiscoverTagsSection.swift
//  DiscoverKit
//
//  Created by Findlay Wood on 30/09/2026.
//

import SwiftUI

/// A subject's tags on its detail screen. Each visible tag opens its page; the
/// user's own votes that are not visible yet sit after them, outlined.
///
/// The Tag button is absent on the user's own workout — an author's tags are
/// edited in the builder, not voted on. A long press on a tag reports it, and
/// a tag the user has reported is gone from their view at once.
struct DiscoverTagsSection: View {

    @ObservedObject var viewModel: DiscoverTaggingViewModel
    @ObservedObject var moderation: DiscoverModerationStore
    let onTagTapped: (String) -> Void

    @State private var reportRequest: DiscoverReportRequest?

    private var tags: [String] {
        viewModel.shownTags.filter { !moderation.hides(tag: $0) }
    }

    var body: some View {
        SectionContainer(
            title: "Tags",
            headerTrailing: viewModel.canVote
                ? AnyView(DiscoverHeaderButton(title: "Tag", systemImage: "plus") { viewModel.isSheetPresented = true })
                : nil
        ) {
            if tags.isEmpty {
                DiscoverSectionMessage(message: viewModel.canVote ? "No tags yet — add the first." : "No tags yet")
            } else {
                DiscoverFlowLayout {
                    ForEach(tags, id: \.self) { tag in
                        DiscoverTagChip(tag: tag, style: style(for: tag))
                            .onTapGesture { onTagTapped(tag) }
                            .contextMenu {
                                Button("Report #\(tag)", systemImage: "flag") {
                                    reportRequest = DiscoverReportRequest(target: .tag(tag))
                                }
                            }
                    }
                }
                .padding(16)
            }
        }
        .sheet(isPresented: $viewModel.isSheetPresented) {
            DiscoverTagSheet(viewModel: viewModel)
                .presentationDetents([.medium, .large])
        }
        .sheet(item: $reportRequest) { request in
            DiscoverReportSheet(target: request.target, moderation: moderation)
                .presentationDetents([.medium])
        }
    }

    private func style(for tag: String) -> DiscoverTagChip.Style {
        if !viewModel.visibleTags.contains(tag) { return .pending }
        return viewModel.isMine(tag) ? .mine : .plain
    }
}
