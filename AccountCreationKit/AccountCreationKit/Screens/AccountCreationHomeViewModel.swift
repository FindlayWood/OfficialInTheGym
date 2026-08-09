//
//  AccountCreationHomeViewModel.swift
//  AccountCreationKit
//
//  Created by Findlay Wood on 09/08/2026.
//

import Combine
import UIKit

class AccountCreationHomeViewModel: ObservableObject {

    // MARK: - Steps

    @Published var page: Int = 0

    // MARK: - User

    let email: String
    let uid: String

    // MARK: - Entered Details

    @Published var username: String = "" {
        didSet {
            if username.count > usernameLimit && oldValue.count <= usernameLimit {
                username = oldValue
            }
        }
    }
    @Published var isUsernameValid: UsernameValidity = .idle

    @Published var displayName: String = "" {
        didSet {
            if displayName.count > displayNameLimit && oldValue.count <= displayNameLimit {
                displayName = oldValue
            }
        }
    }

    @Published var bio: String = "" {
        didSet {
            if bio.count > bioLimit && oldValue.count <= bioLimit {
                bio = oldValue
            }
        }
    }

    let usernameLimit: Int = 50
    let displayNameLimit: Int = 100
    let bioLimit: Int = 300

    @Published var selectedAccountType: AccountType?

    @Published var profileImage: UIImage?

    @Published var uploading: Bool = false

    @Published var accountCreated: Bool = false

    var canCreateAccount: Bool {
        isUsernameValid == .valid && selectedAccountType != nil && !displayName.isEmpty
    }

    // MARK: - Dependencies

    private let usernameChecker: UsernameAvailabilityChecker
    private let usernameReserver: UsernameReserver
    private let accountCreator: AccountCreator
    private let profileImageUploader: ProfileImageUploader
    private let signOutService: AccountCreationSignOutService

    private let onAccountCreated: () -> Void
    private let onSignedOut: () -> Void

    private var subscriptions = Set<AnyCancellable>()

    // MARK: - Init

    init(
        user: AccountCreationUserModel,
        usernameChecker: UsernameAvailabilityChecker,
        usernameReserver: UsernameReserver,
        accountCreator: AccountCreator,
        profileImageUploader: ProfileImageUploader,
        signOutService: AccountCreationSignOutService,
        onAccountCreated: @escaping () -> Void,
        onSignedOut: @escaping () -> Void
    ) {
        self.email = user.email
        self.uid = user.uid
        self.usernameChecker = usernameChecker
        self.usernameReserver = usernameReserver
        self.accountCreator = accountCreator
        self.profileImageUploader = profileImageUploader
        self.signOutService = signOutService
        self.onAccountCreated = onAccountCreated
        self.onSignedOut = onSignedOut
        usernameListener()
    }

    // MARK: - Username

    func usernameListener() {
        $username
            .dropFirst(4)
            .sink { [weak self] in self?.checkUsername($0) }
            .store(in: &subscriptions)
    }

    func checkUsername(_ text: String) {
        isUsernameValid = .checking
        let usernameRegEx = "[A-Za-z0-9_.]{3,50}$"

        let usernamePred = NSPredicate(format: "SELF MATCHES %@", usernameRegEx)
        if usernamePred.evaluate(with: text) {
            Task { @MainActor in
                do {
                    isUsernameValid = try await usernameChecker.isUsernameAvailable(text) ? .valid : .taken
                } catch {
                    // A failed lookup currently reads as "taken", so a network blip blocks a name
                    // that is actually free. Preserved from the original for now — the fix belongs
                    // with the UI pass, which needs a state to show it in.
                    print(String(describing: error))
                    isUsernameValid = .taken
                }
            }
        } else {
            if text.count == 0 {
                isUsernameValid = .idle
            } else if text.count < 3 {
                isUsernameValid = .tooShort
            } else {
                isUsernameValid = .invalid
            }
        }
    }

    // MARK: - Creation

    @MainActor
    func createAccount() {
        guard let selectedAccountType else { return }
        uploading = true

        let newAccountModel = CreateAccountModel(
            uid: uid,
            email: email,
            username: username.trimTrailingWhiteSpaces(),
            displayName: displayName.trimTrailingWhiteSpaces(),
            bio: bio.trimTrailingWhiteSpaces(),
            accountType: selectedAccountType
        )

        Task {
            let reservedUsername = await reserveUsername()
            if reservedUsername {
                do {
                    try await accountCreator.createAccount(newAccountModel)
                    if profileImage != nil {
                        uploadProfileImage()
                    }
                    onAccountCreated()
                } catch {
                    // failed to upload account
                    print(String(describing: error))
                    uploading = false
                }
            } else {
                // error with username already being taken
                username.removeAll()
                uploading = false
            }
        }
    }

    func reserveUsername() async -> Bool {
        do {
            try await usernameReserver.reserveUsername(username, for: uid)
            return true
        } catch {
            print("error reserving username")
            print(String(describing: error))
            return false
        }
    }

    func uploadProfileImage() {
        guard let data = profileImage?.jpegData(compressionQuality: 0.1) else { return }
        Task {
            do {
                try await profileImageUploader.uploadProfileImage(data, for: uid)
            } catch {
                print(String(describing: error))
            }
        }
    }

    // MARK: - Sign Out

    func signOutAction() {
        Task {
            do {
                try await signOutService.signOut()
                onSignedOut()
            } catch {
                print(String(describing: error))
            }
        }
    }
}
