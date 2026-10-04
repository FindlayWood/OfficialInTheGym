//
//  EditProfileScreen.swift
//  ProfileKit
//
//  Created by Findlay Wood on 03/10/2026.
//

import PhotosUI
import SwiftUI

/// Edit Profile, presented modally in its own navigation controller with
/// Cancel and Done. See `EditProfileViewModel` for what Done saves and in what
/// order.
///
/// Modal rather than pushed, for the reason Forgot Password got its Cancel
/// button: a pushed screen's way out is "back", which reads as keeping the
/// edits. Here leaving without Done discards them, and the button says so.
///
/// The `PhotosPicker` wraps the avatar itself, with a camera badge, as on the
/// account-creation profile step. Tapping the picture is what people try first.
struct EditProfileScreen: View {

    @ObservedObject var viewModel: EditProfileViewModel
    @State private var photoItem: PhotosPickerItem?

    var body: some View {
        ScrollView {
            VStack(spacing: 16) {
                avatarPicker
                    .padding(.vertical, 8)

                EditProfileFieldCard(
                    title: "Display Name",
                    icon: "person",
                    counter: "\(viewModel.displayName.count)/\(ProfileDetails.displayNameLimit)",
                    footer: viewModel.details.displayName.isEmpty ? "Your display name can't be empty." : nil
                ) {
                    TextField("Your name", text: $viewModel.displayName)
                        .font(.system(size: 16))
                        .tint(Color.darkColor)
                        .textContentType(.name)
                        .submitLabel(.done)
                }

                EditProfileFieldCard(
                    title: "Bio",
                    icon: "text.alignleft",
                    counter: "\(viewModel.bio.count)/\(ProfileDetails.bioLimit)"
                ) {
                    TextField("Write something about you...", text: $viewModel.bio, axis: .vertical)
                        .font(.system(size: 16))
                        .tint(Color.darkColor)
                        .lineLimit(4...8)
                }

                if let message = viewModel.errorMessage {
                    ProfileErrorBanner(message: message)
                }
            }
            .padding(16)
        }
        .scrollDismissesKeyboard(.interactively)
        .background(Color(.systemBackground).ignoresSafeArea())
        .navigationTitle("Edit Profile")
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
                    Button("Done") { Task { await viewModel.save() } }
                        .fontWeight(.semibold)
                        .disabled(!viewModel.canSave)
                }
            }
        }
        .tint(Color.darkColor)
        // No swipe-away with unsaved edits, or mid-save. Swiping would discard
        // the edits without the word "Cancel" on screen to say so, or leave the
        // user unsure what had been kept.
        .interactiveDismissDisabled(viewModel.isSaving || viewModel.hasChanges)
        .onChange(of: photoItem) { _, newItem in
            Task {
                guard let data = try? await newItem?.loadTransferable(type: Data.self),
                      let image = UIImage(data: data) else { return }
                viewModel.pickPhoto(image)
            }
        }
    }

    private var avatarPicker: some View {
        PhotosPicker(selection: $photoItem, matching: .any(of: [.images, .not(.videos)])) {
            ZStack(alignment: .bottomTrailing) {
                ProfileAvatar(photo: viewModel.photo, size: 112)
                Circle()
                    .fill(Color.darkColor)
                    .frame(width: 34, height: 34)
                    .overlay(
                        Image(systemName: "camera.fill")
                            .font(.system(size: 14, weight: .semibold))
                            .foregroundStyle(Color.white)
                    )
                    .overlay(
                        Circle().stroke(Color(.systemBackground), lineWidth: 3)
                    )
            }
        }
        .buttonStyle(.plain)
        .disabled(viewModel.isSaving)
        .accessibilityLabel("Change profile photo")
        .frame(maxWidth: .infinity)
    }
}

#Preview {
    NavigationStack {
        EditProfileScreen(
            viewModel: EditProfileViewModel(
                header: .preview,
                photo: nil,
                detailsWriter: PreviewProfileEditServices(),
                photoUploader: PreviewProfileEditServices()
            )
        )
    }
}
