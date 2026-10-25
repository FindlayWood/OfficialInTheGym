//
//  DiscoverBodyPartsSection.swift
//  DiscoverKit
//
//  Created by Findlay Wood on 25/10/2026.
//

import SwiftUI

/// "Works: Chest · Triceps · Push Horizontal" on an exercise's page, with a
/// Suggest button that opens `DiscoverBodyPartsSheet`.
struct DiscoverBodyPartsSection: View {

    @ObservedObject var viewModel: DiscoverBodyPartsViewModel

    var body: some View {
        SectionContainer(
            title: "Works",
            headerTrailing: viewModel.parts == nil
                ? nil
                : AnyView(DiscoverHeaderButton(title: "Suggest", systemImage: "pencil") { viewModel.openSheet() })
        ) {
            VStack(alignment: .leading, spacing: 8) {
                if viewModel.parts == nil {
                    if viewModel.didFailToLoad {
                        DiscoverSectionMessage(message: "Couldn't load what this works.")
                    } else {
                        ProgressView().frame(maxWidth: .infinity).padding(.vertical, 8)
                    }
                } else if viewModel.worksNames.isEmpty {
                    DiscoverSectionMessage(message: "Not set yet — suggest what it works.")
                } else {
                    Text(viewModel.worksNames.joined(separator: " · "))
                        .font(.system(size: 15, weight: .medium))
                        .foregroundStyle(.primary)
                        .frame(maxWidth: .infinity, alignment: .leading)
                }
                if viewModel.myVote != nil {
                    Label("You suggested a change. A reviewer will look at it.", systemImage: "checkmark.circle")
                        .font(.system(size: 12, weight: .medium))
                        .foregroundStyle(.secondary)
                }
            }
            .padding(16)
        }
        .sheet(isPresented: $viewModel.isSheetPresented) {
            DiscoverBodyPartsSheet(viewModel: viewModel)
                .presentationDetents([.large])
        }
    }
}
