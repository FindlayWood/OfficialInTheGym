//
//  ProfileStepView.swift
//  AccountCreationKit
//
//  Created by Findlay Wood on 09/08/2026.
//

import PhotosUI
import SwiftUI

/// Photo and bio on one step. They were a step each, and neither is required — two screens that can
/// both be walked past without typing anything are two screens too many.
///
/// Nothing here gates the bottom button, and the step subtitle says both are optional, so "Continue"
/// is the skip. A separate Skip button would have said the same thing twice.
struct ProfileStepView: View {

    @ObservedObject var viewModel: AccountCreationHomeViewModel

    @State private var avatarItem: PhotosPickerItem?
    @FocusState private var bioFocused: Bool

    var body: some View {
        ScrollView(showsIndicators: false) {
            VStack(spacing: 20) {
                AccountCreationStepHeader(step: .profile)

                // MARK: Avatar
                // The picker wraps the avatar itself rather than sitting under it as a text link:
                // tapping the picture is what everyone tries first, and the old 300pt grey
                // `person.circle.fill` placeholder swamped the screen for something optional.
                PhotosPicker(selection: $avatarItem, matching: .any(of: [.images, .not(.videos)])) {
                    ZStack(alignment: .bottomTrailing) {
                        avatar
                        Circle()
                            .fill(Color.darkColor)
                            .frame(width: 34, height: 34)
                            .overlay(
                                Image(systemName: "camera.fill")
                                    .font(.system(size: 14, weight: .semibold))
                                    .foregroundStyle(Color.white)
                            )
                            .overlay(
                                Circle()
                                    .stroke(Color(.systemBackground), lineWidth: 3)
                            )
                    }
                }
                .buttonStyle(.plain)
                .frame(maxWidth: .infinity)

                // MARK: Bio
                AccountCreationFieldCard(
                    title: "Bio",
                    icon: "text.alignleft",
                    counter: "\(viewModel.bio.count)/\(viewModel.bioLimit)"
                ) {
                    TextField(
                        "Write something about you...",
                        text: $viewModel.bio,
                        axis: .vertical
                    )
                    .font(.system(size: 16))
                    .tint(Color.darkColor)
                    .lineLimit(4...8)
                    .focused($bioFocused)
                }
            }
            .padding(.horizontal, 20)
            .padding(.top, 12)
            .padding(.bottom, 24)
        }
        .scrollDismissesKeyboard(.interactively)
        .onChange(of: avatarItem) { _, newItem in
            Task {
                guard let data = try? await newItem?.loadTransferable(type: Data.self),
                      let uiImage = UIImage(data: data) else { return }
                viewModel.profileImage = uiImage
            }
        }
    }

    @ViewBuilder
    private var avatar: some View {
        if let profileImage = viewModel.profileImage {
            Image(uiImage: profileImage)
                .resizable()
                .scaledToFill()
                .frame(width: 120, height: 120)
                .clipShape(Circle())
        } else {
            Circle()
                .fill(Color(.secondarySystemBackground))
                .frame(width: 120, height: 120)
                .overlay(
                    Image(systemName: "person.fill")
                        .font(.system(size: 44, weight: .light))
                        .foregroundStyle(Color(.tertiaryLabel))
                )
        }
    }
}

#Preview {
    ProfileStepView(viewModel: .preview)
}
