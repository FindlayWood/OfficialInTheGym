//
//  ReviewStepView.swift
//  AccountCreationKit
//
//  Created by Findlay Wood on 09/08/2026.
//

import SwiftUI

/// The profile as it will read, then the account it will be tied to.
///
/// **Anything missing is a button that jumps to the step that fixes it.** This screen used to print
/// the same complaints as flat red text with no way to act on them — the user had to work out which
/// of the earlier steps each one belonged to and chevron back through the flow to find it.
struct ReviewStepView: View {

    @ObservedObject var viewModel: AccountCreationHomeViewModel

    var body: some View {
        ScrollView(showsIndicators: false) {
            VStack(spacing: 20) {
                AccountCreationStepHeader(step: .review)

                profileCard

                if !missing.isEmpty {
                    VStack(spacing: 8) {
                        ForEach(missing, id: \.message) { item in
                            Button {
                                withAnimation(.easeInOut(duration: 0.25)) { viewModel.step = item.step }
                            } label: {
                                HStack(spacing: 10) {
                                    Image(systemName: "exclamationmark.circle.fill")
                                        .font(.system(size: 15))
                                        .foregroundStyle(Color.red)
                                    Text(item.message)
                                        .font(.system(size: 14, weight: .medium))
                                        .foregroundStyle(Color.primary)
                                        .multilineTextAlignment(.leading)
                                    Spacer(minLength: 0)
                                    Image(systemName: "chevron.right")
                                        .font(.system(size: 13, weight: .semibold))
                                        .foregroundStyle(.tertiary)
                                }
                                .padding(.horizontal, 16)
                                .padding(.vertical, 13)
                                .background(
                                    RoundedRectangle(cornerRadius: 14, style: .continuous)
                                        .fill(Color.red.opacity(0.12))
                                )
                            }
                            .buttonStyle(.plain)
                        }
                    }
                }

                // The email is not editable here, but it is the one thing on this screen the user
                // did not just type — worth confirming which address the account is being tied to
                // before it is created.
                HStack(spacing: 10) {
                    Image(systemName: "envelope.fill")
                        .font(.system(size: 13, weight: .semibold))
                        .foregroundStyle(Color.darkColor)
                    Text(viewModel.email)
                        .font(.system(size: 14))
                        .foregroundStyle(Color.secondary)
                        .lineLimit(1)
                        .truncationMode(.middle)
                    Spacer(minLength: 0)
                }
                .padding(.horizontal, 16)
                .padding(.vertical, 13)
                .background(
                    RoundedRectangle(cornerRadius: 14, style: .continuous)
                        .fill(Color(.secondarySystemBackground))
                )
            }
            .padding(.horizontal, 20)
            .padding(.top, 12)
            .padding(.bottom, 24)
        }
    }

    // MARK: - Profile Card

    private var profileCard: some View {
        VStack(spacing: 12) {
            avatar

            VStack(spacing: 2) {
                Text(viewModel.displayName.isEmpty ? "Your name" : viewModel.displayName)
                    .font(.system(size: 20, weight: .bold))
                    .foregroundStyle(viewModel.displayName.isEmpty ? Color(.tertiaryLabel) : Color.primary)
                Text(viewModel.username.isEmpty ? "@username" : "@\(viewModel.username)")
                    .font(.system(size: 15, weight: .medium))
                    .foregroundStyle(Color.secondary)
            }

            if !bodyChips.isEmpty {
                HStack(spacing: 8) {
                    ForEach(bodyChips, id: \.self) { chip in
                        Text(chip)
                            .font(.system(size: 13, weight: .semibold))
                            .foregroundStyle(Color.darkColor)
                            .padding(.horizontal, 12)
                            .padding(.vertical, 7)
                            .background(Capsule().fill(Color.darkColor.opacity(0.12)))
                    }
                }
            }

            if !viewModel.bio.trimTrailingWhiteSpaces().isEmpty {
                Text(viewModel.bio)
                    .font(.system(size: 14))
                    .foregroundStyle(Color.secondary)
                    .multilineTextAlignment(.center)
                    .fixedSize(horizontal: false, vertical: true)
                    .padding(.top, 2)
            }
        }
        .frame(maxWidth: .infinity)
        .padding(20)
        .background(
            RoundedRectangle(cornerRadius: 16, style: .continuous)
                .fill(Color(.secondarySystemBackground))
        )
    }

    @ViewBuilder
    private var avatar: some View {
        if let profileImage = viewModel.profileImage {
            Image(uiImage: profileImage)
                .resizable()
                .scaledToFill()
                .frame(width: 88, height: 88)
                .clipShape(Circle())
        } else {
            Circle()
                .fill(Color(.tertiarySystemBackground))
                .frame(width: 88, height: 88)
                .overlay(
                    Image(systemName: "person.fill")
                        .font(.system(size: 34, weight: .light))
                        .foregroundStyle(Color(.tertiaryLabel))
                )
        }
    }

    // MARK: - Missing

    private struct MissingRequirement {
        let message: String
        let step: AccountCreationStep
    }

    /// Height, weight and age are optional, so they are shown when present and simply absent when
    /// not — they never appear in `missing`, which is only for things that block creation.
    private var bodyChips: [String] {
        var chips = [String]()
        if let centimetres = viewModel.heightCentimetres {
            chips.append(HeightUnit.display(centimetres: centimetres, in: viewModel.heightUnit))
        }
        if let kilograms = viewModel.weightKilograms {
            chips.append(BodyWeightUnit.display(kilograms: kilograms, in: viewModel.weightUnit))
        }
        if let dateOfBirth = viewModel.dateOfBirth,
           let age = Calendar.current.dateComponents([.year], from: dateOfBirth, to: .now).year {
            // Carries its unit like the other two — "31" beside "180 cm" and "82 kg" reads as a
            // measurement with the unit missing.
            chips.append("\(age) yrs")
        }
        return chips
    }

    private var missing: [MissingRequirement] {
        var items = [MissingRequirement]()
        if !viewModel.isDisplayNameComplete {
            items.append(.init(message: "Add a display name", step: .details))
        }
        if !viewModel.isUsernameComplete {
            items.append(.init(message: "Pick an available username", step: .details))
        }
        return items
    }
}

#Preview {
    ReviewStepView(viewModel: .preview)
}
