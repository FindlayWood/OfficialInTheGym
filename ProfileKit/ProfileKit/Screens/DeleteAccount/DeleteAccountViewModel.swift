//
//  DeleteAccountViewModel.swift
//  ProfileKit
//
//  Created by Findlay Wood on 04/10/2026.
//

import Combine
import Foundation

/// Deleting the account (`PROFILE_PLAN.md` step 10): say plainly what goes,
/// ask for the password, then a last confirmation before the button does it.
///
/// **Two deliberate steps, not one.** The password proves who is holding the
/// phone, and the final alert ("This can't be undone") is the moment to
/// change one's mind. Neither alone is enough for something permanent.
///
/// On success the adapter ends the session and the app leaves for the welcome
/// screen, so this view model has no success state to show. On failure it says
/// what went wrong. A wrong password clears the field; anything else keeps it,
/// so retrying costs one tap. Retrying is always safe, because the server
/// finishes whatever a failed attempt left.
@MainActor
final class DeleteAccountViewModel: ObservableObject {

    @Published var password = "" {
        didSet { if errorMessage != nil, password != oldValue { errorMessage = nil } }
    }
    @Published private(set) var isDeleting = false
    @Published private(set) var errorMessage: String?

    private let deleter: AccountDeleter

    init(deleter: AccountDeleter) {
        self.deleter = deleter
    }

    var canDelete: Bool {
        !password.isEmpty && !isDeleting
    }

    func delete() async {
        guard canDelete else { return }
        isDeleting = true
        errorMessage = nil
        defer { isDeleting = false }
        do {
            try await deleter.deleteAccount(password: password)
        } catch let error as AccountDeletionError {
            switch error {
            case .wrongPassword:
                password = ""
                errorMessage = "That password isn't right. Nothing was deleted."
            case .tooManyAttempts:
                errorMessage = "Too many attempts. Wait a few minutes, then try again."
            case .failed:
                errorMessage = "Couldn't delete your account. Check your connection and try again."
            }
        } catch {
            print("❌ Account deletion failed: \(error)")
            errorMessage = "Couldn't delete your account. Check your connection and try again."
        }
    }
}
