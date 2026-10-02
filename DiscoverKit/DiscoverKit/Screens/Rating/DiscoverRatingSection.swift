//
//  DiscoverRatingSection.swift
//  DiscoverKit
//
//  Created by Findlay Wood on 30/09/2026.
//

import SwiftUI

/// The rating card on a detail screen: the average large, how many ratings it
/// is from, and the user's own rating as the action.
///
/// With no ratings the average reads "—" and says so, never "0.0" — an
/// absence drawn as a score.
struct DiscoverRatingSection: View {

    @ObservedObject var viewModel: DiscoverRatingViewModel

    var body: some View {
        SectionContainer(title: "Rating") {
            VStack(alignment: .leading, spacing: 0) {
                HStack(alignment: .firstTextBaseline, spacing: 6) {
                    Text(viewModel.summary.formattedAverage)
                        .font(.system(size: 34, weight: .bold))
                        .foregroundStyle(Color.darkColor)
                    Text("/ 10")
                        .font(.system(size: 15, weight: .semibold))
                        .foregroundStyle(.secondary)
                    Spacer()
                    Text(countText)
                        .font(.system(size: 13))
                        .foregroundStyle(.secondary)
                }
                .padding(16)

                Divider()

                action
            }
        }
        .sheet(isPresented: $viewModel.isSheetPresented) {
            DiscoverRatingSheet(currentRating: viewModel.myRating) { rating in
                viewModel.isSheetPresented = false
                Task { await viewModel.rate(rating) }
            }
            .presentationDetents([.height(260)])
        }
    }

    private var countText: String {
        switch viewModel.summary.count {
        case 0: return "No ratings yet"
        case 1: return "1 rating"
        default: return "\(viewModel.summary.count) ratings"
        }
    }

    @ViewBuilder
    private var action: some View {
        if viewModel.canRate {
            Button {
                viewModel.isSheetPresented = true
            } label: {
                HStack {
                    Text(viewModel.myRating == nil ? "Rate this" : "Your rating")
                        .font(.system(size: 15, weight: .semibold))
                        .foregroundStyle(.primary)
                    Spacer()
                    if let mine = viewModel.myRating {
                        Text("\(mine)")
                            .font(.system(size: 15, weight: .bold))
                            .foregroundStyle(Color.darkColor)
                    }
                    Image(systemName: "chevron.right")
                        .font(.system(size: 13, weight: .semibold))
                        .foregroundStyle(.tertiary)
                }
                .padding(16)
                .contentShape(Rectangle())
            }
            .buttonStyle(.plain)

            if viewModel.didFailToSave {
                Text("Couldn't save your rating. Try again.")
                    .font(.system(size: 13))
                    .foregroundStyle(.secondary)
                    .padding(.horizontal, 16)
                    .padding(.bottom, 12)
            }
        } else {
            Text("You can't rate your own workout")
                .font(.system(size: 14))
                .foregroundStyle(.secondary)
                .padding(16)
        }
    }
}
