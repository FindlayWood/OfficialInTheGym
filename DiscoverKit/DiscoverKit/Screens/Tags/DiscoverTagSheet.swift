//
//  DiscoverTagSheet.swift
//  DiscoverKit
//
//  Created by Findlay Wood on 30/09/2026.
//

import SwiftUI

/// Voting on a subject's tags: type one to add it, tap any existing one to add
/// or withdraw your vote. Changes apply as they are made, so Done only
/// dismisses — the same contract as every sheet in the app.
struct DiscoverTagSheet: View {

    @ObservedObject var viewModel: DiscoverTaggingViewModel
    @Environment(\.dismiss) private var dismiss

    var body: some View {
        VStack(alignment: .leading, spacing: 0) {
            HStack(alignment: .top) {
                VStack(alignment: .leading, spacing: 3) {
                    Text("Tags")
                        .font(.system(size: 16, weight: .semibold))
                    Text("A tag shows to everyone once 3 people add it")
                        .font(.system(size: 13))
                        .foregroundStyle(.secondary)
                }
                Spacer()
                Button("Done") { dismiss() }
                    .font(.system(size: 15, weight: .semibold))
                    .foregroundStyle(Color.darkColor)
            }
            .padding(20)

            Divider()

            ScrollView {
                VStack(alignment: .leading, spacing: 18) {
                    field

                    if !viewModel.suggestions.isEmpty {
                        DiscoverFlowLayout {
                            ForEach(viewModel.suggestions) { suggestion in
                                DiscoverTagChip(tag: suggestion.tag, count: suggestion.totalCount)
                                    .onTapGesture { Task { await viewModel.toggle(suggestion.tag); viewModel.query = "" } }
                            }
                        }
                    }

                    if !viewModel.votableTags.isEmpty {
                        Text("TAP TO ADD OR REMOVE YOUR VOTE")
                            .font(.system(size: 12, weight: .semibold))
                            .foregroundStyle(.secondary)
                        DiscoverFlowLayout {
                            ForEach(viewModel.votableTags, id: \.self) { tag in
                                DiscoverTagChip(
                                    tag: tag,
                                    count: viewModel.counts[tag],
                                    style: viewModel.isMine(tag) ? .mine : .plain
                                )
                                .onTapGesture { Task { await viewModel.toggle(tag) } }
                            }
                        }
                    }

                    if !viewModel.canAddMore {
                        note("You've used all \(DiscoverTaggingViewModel.maxMyTags) of your tags here. Remove one to add another.")
                    }
                    if viewModel.didFailToSave {
                        note("Couldn't save your tags. Try again.")
                    }
                }
                .padding(20)
            }
        }
        .task { await viewModel.load() }
    }

    private var field: some View {
        HStack(spacing: 10) {
            TextField("Add a tag", text: $viewModel.query)
                .textInputAutocapitalization(.never)
                .autocorrectionDisabled()
                .font(.system(size: 15))
                .padding(.horizontal, 14)
                .padding(.vertical, 12)
                .background(Color(.tertiarySystemBackground), in: RoundedRectangle(cornerRadius: 14))
                .onSubmit { Task { await viewModel.addQuery() } }

            let canAdd = !viewModel.query.isEmpty && viewModel.canAddMore
            Button {
                Task { await viewModel.addQuery() }
            } label: {
                Text("Add")
                    .font(.system(size: 15, weight: .semibold))
                    .foregroundStyle(canAdd ? .white : Color.secondary)
                    .padding(.horizontal, 16)
                    .frame(height: 44)
                    .background(
                        RoundedRectangle(cornerRadius: 14)
                            .fill(canAdd ? Color.darkColor : Color(UIColor.tertiarySystemFill))
                    )
            }
            .buttonStyle(.plain)
            .disabled(!canAdd)
            .animation(.easeInOut(duration: 0.15), value: canAdd)
        }
    }

    private func note(_ text: String) -> some View {
        Text(text)
            .font(.system(size: 13))
            .foregroundStyle(.secondary)
    }
}
