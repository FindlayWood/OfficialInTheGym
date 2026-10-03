//
//  EditProfileViewModel.swift
//  ProfileKit
//
//  Created by Findlay Wood on 03/10/2026.
//

import Combine
import UIKit

/// Edit Profile: photo, display name and bio (`PROFILE_PLAN.md` step 3).
///
/// **Done saves everything and Cancel discards everything, the photo
/// included.** A photo that uploaded the moment it was picked, beside text that
/// waits for Done, would make Cancel mean "discard some of this", and no screen
/// should need explaining. Nothing reaches the server until Done.
///
/// **The photo goes first, then the text.** If the photo fails, nothing is
/// written and the screen stays open with its error. If the photo succeeds and
/// the text fails, the photo is remembered as saved (`savedPhoto`), so pressing
/// Done again retries only the text rather than uploading the same picture
/// twice.
///
/// Done with nothing changed just closes. The two text fields cap at the
/// account-creation limits by refusing the extra character, as signup does,
/// rather than letting the user type past a limit only Done would reveal.
@MainActor
final class EditProfileViewModel: ObservableObject {

    @Published var displayName: String {
        didSet {
            if displayName.count > ProfileDetails.displayNameLimit && oldValue.count <= ProfileDetails.displayNameLimit {
                displayName = oldValue
            }
        }
    }

    @Published var bio: String {
        didSet {
            if bio.count > ProfileDetails.bioLimit && oldValue.count <= ProfileDetails.bioLimit {
                bio = oldValue
            }
        }
    }

    /// The photo on screen: the current one, or a newly picked one not yet saved.
    @Published private(set) var photo: UIImage?
    @Published private(set) var isSaving = false
    @Published private(set) var errorMessage: String?

    private let original: ProfileDetails
    private var pickedPhoto: UIImage?
    private var savedPhoto: UIImage?

    private let detailsWriter: ProfileDetailsWriter
    private let photoUploader: ProfilePhotoUploader

    /// Called after anything was saved, before the screen closes, so the
    /// profile behind it can reload.
    var onSaved: (() -> Void)?
    var onFinished: (() -> Void)?

    init(
        header: ProfileHeader,
        photo: UIImage?,
        detailsWriter: ProfileDetailsWriter,
        photoUploader: ProfilePhotoUploader
    ) {
        self.original = ProfileDetails(displayName: header.displayName, bio: header.bio)
        self.displayName = header.displayName
        self.bio = header.bio
        self.photo = photo
        self.detailsWriter = detailsWriter
        self.photoUploader = photoUploader
    }

    var details: ProfileDetails {
        ProfileDetails(displayName: displayName, bio: bio).trimmed
    }

    /// A display name is required, as it is at signup. Every list that shows a
    /// person shows it, and an empty one leaves a row with nothing in it.
    var canSave: Bool {
        !details.displayName.isEmpty && !isSaving
    }

    var hasChanges: Bool {
        details != original.trimmed || pickedPhoto != nil
    }

    func pickPhoto(_ image: UIImage) {
        pickedPhoto = image
        photo = image
        errorMessage = nil
    }

    func cancel() {
        onFinished?()
    }

    func save() async {
        guard canSave else { return }
        guard hasChanges else {
            onFinished?()
            return
        }

        isSaving = true
        errorMessage = nil
        defer { isSaving = false }

        if let pickedPhoto, pickedPhoto !== savedPhoto {
            do {
                try await photoUploader.upload(pickedPhoto)
                savedPhoto = pickedPhoto
            } catch {
                print("❌ Profile photo upload failed: \(error)")
                errorMessage = "Couldn't upload your photo. Check your connection and try again."
                return
            }
        }

        if details != original.trimmed {
            do {
                try await detailsWriter.save(details)
            } catch {
                print("❌ Profile details save failed: \(error)")
                // The photo, if any, is already saved; say so, or the user
                // will assume Done did nothing at all.
                errorMessage = savedPhoto == nil
                    ? "Couldn't save your profile. Check your connection and try again."
                    : "Your photo was saved, but your name and bio weren't. Try again."
                onSaved?()
                return
            }
        }

        onSaved?()
        onFinished?()
    }
}
