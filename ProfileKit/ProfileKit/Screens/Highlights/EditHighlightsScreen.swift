//
//  EditHighlightsScreen.swift
//  ProfileKit
//
//  Created by Findlay Wood on 04/10/2026.
//

import SwiftUI

/// Choosing highlights, presented modally with Cancel and Save, as Edit
/// Profile is. An Automatic row, then every logged exercise with its best,
/// numbered 1–3 in the order picked. See `EditHighlightsViewModel`.
struct EditHighlightsScreen: View {

    @ObservedObject var viewModel: EditHighlightsViewModel

    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 16) {
                Text("Choose up to three exercises to show on your profile, or leave it on Automatic to show your most-trained.")
                    .font(.system(size: 14))
                    .foregroundStyle(Color.secondary)
                    .fixedSize(horizontal: false, vertical: true)
                    .padding(.horizontal, 4)

                if let message = viewModel.errorMessage {
                    ProfileErrorBanner(message: message)
                }

                switch viewModel.loadState {
                case .loading:
                    ProgressView()
                        .frame(maxWidth: .infinity)
                        .padding(.vertical, 40)
                case .failed:
                    ProfileLoadFailedCard(title: "Couldn't Load Your Exercises") {
                        Task { await viewModel.load() }
                    }
                case .loaded:
                    automaticRow
                    if viewModel.candidates.isEmpty {
                        Text("Nothing logged yet. Exercises appear here once you've logged a set.")
                            .font(.system(size: 14))
                            .foregroundStyle(Color.secondary)
                            .padding(.horizontal, 4)
                    } else {
                        candidateList
                    }
                }
            }
            .padding(16)
        }
        .background(Color(.systemBackground).ignoresSafeArea())
        .navigationTitle("Highlights")
        .navigationBarTitleDisplayMode(.inline)
        .toolbar {
            ToolbarItem(placement: .cancellationAction) {
                Button("Cancel") { viewModel.cancel() }
                    .disabled(viewModel.isSaving)
            }
            ToolbarItem(placement: .confirmationAction) {
                if viewModel.isSaving {
                    ProgressView()
                } else {
                    Button("Save") { Task { await viewModel.save() } }
                        .fontWeight(.semibold)
                        .disabled(viewModel.loadState != .loaded)
                }
            }
        }
        .tint(Color.darkColor)
        .interactiveDismissDisabled(viewModel.isSaving || viewModel.hasChanges)
        .task { await viewModel.load() }
    }

    private var automaticRow: some View {
        Button {
            viewModel.useAutomatic()
        } label: {
            HStack(spacing: 12) {
                Image(systemName: "sparkles")
                    .font(.system(size: 16, weight: .semibold))
                    .foregroundStyle(Color.darkColor)
                    .frame(width: 28)
                VStack(alignment: .leading, spacing: 2) {
                    Text("Automatic")
                        .font(.system(size: 15, weight: .semibold))
                        .foregroundStyle(Color.primary)
                    Text("Your three most-trained exercises")
                        .font(.system(size: 13))
                        .foregroundStyle(Color.secondary)
                }
                Spacer()
                if viewModel.isAutomatic {
                    Image(systemName: "checkmark.circle.fill")
                        .font(.system(size: 20))
                        .foregroundStyle(Color.darkColor)
                }
            }
            .padding(14)
            .background(
                RoundedRectangle(cornerRadius: 16, style: .continuous)
                    .fill(Color(.secondarySystemBackground))
            )
        }
        .buttonStyle(.plain)
    }

    private var candidateList: some View {
        VStack(spacing: 0) {
            ForEach(Array(viewModel.candidates.enumerated()), id: \.element.id) { index, candidate in
                Button {
                    viewModel.toggle(candidate.exerciseId)
                } label: {
                    HStack(spacing: 12) {
                        badge(viewModel.position(of: candidate.exerciseId))
                        Text(candidate.exerciseName.isEmpty ? "Exercise" : candidate.exerciseName)
                            .font(.system(size: 15, weight: .medium))
                            .foregroundStyle(Color.primary)
                            .lineLimit(1)
                        Spacer(minLength: 8)
                        Text(candidate.valueText)
                            .font(.system(size: 14, weight: .semibold).monospacedDigit())
                            .foregroundStyle(Color.secondary)
                    }
                    .padding(.horizontal, 14)
                    .frame(minHeight: 50)
                    .contentShape(Rectangle())
                }
                .buttonStyle(.plain)
                if index < viewModel.candidates.count - 1 {
                    Divider().padding(.leading, 54)
                }
            }
        }
        .background(
            RoundedRectangle(cornerRadius: 16, style: .continuous)
                .fill(Color(.secondarySystemBackground))
        )
    }

    /// The pick's number in a filled circle, or an empty ring.
    @ViewBuilder
    private func badge(_ position: Int?) -> some View {
        if let position {
            Text("\(position)")
                .font(.system(size: 13, weight: .bold))
                .foregroundStyle(Color.white)
                .frame(width: 28, height: 28)
                .background(Color.darkColor, in: Circle())
        } else {
            Circle()
                .stroke(Color(.tertiaryLabel), lineWidth: 1.5)
                .frame(width: 24, height: 24)
                .frame(width: 28, height: 28)
        }
    }
}
