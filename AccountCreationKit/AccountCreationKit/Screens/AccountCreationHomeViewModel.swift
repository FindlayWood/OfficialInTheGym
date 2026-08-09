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

    @Published var step: AccountCreationStep = .details

    // MARK: - User

    let email: String
    let uid: String

    // MARK: - Entered Details

    /// Held lowercase. `Usernames/{username}` is a case-sensitive Firestore document id, so
    /// `Findlay` and `findlay` would be two different reservations — and iOS capitalises the first
    /// letter of a text field by default, which is how a user who typed lowercase ended up with a
    /// capitalised name they never chose. The field also sets `.textInputAutocapitalization(.never)`;
    /// this is the half that a paste cannot get around.
    @Published var username: String = "" {
        didSet {
            guard username != oldValue else { return }
            if username.count > usernameLimit {
                username = oldValue
                return
            }
            let normalised = username.lowercased()
            if normalised != username {
                username = normalised
                return
            }
            usernameError = nil
            isUsernameValid = username.isEmpty ? .idle : .checking
        }
    }
    @Published var isUsernameValid: UsernameValidity = .idle

    /// Set when a username that passed the availability check was taken before we could reserve it.
    @Published var usernameError: String?

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

    @Published var profileImage: UIImage?

    // MARK: - Body
    //
    // All optional, and all stored canonically — centimetres and kilograms — with the entry unit
    // kept alongside so the value reads back the way it was typed.

    @Published var heightCentimetres: Double?
    @Published var weightKilograms: Double?
    @Published var dateOfBirth: Date?

    /// The unit last used to enter each measure. Metric by default.
    @Published var heightUnit: HeightUnit = .centimetres
    @Published var weightUnit: BodyWeightUnit = .kilograms

    @Published var uploading: Bool = false

    /// Shown above the bottom button. Account creation used to fail silently — the spinner
    /// disappeared and the user was left on the last screen of onboarding with no way to tell
    /// whether it had worked.
    @Published var creationError: String?

    // MARK: - Validation

    var isUsernameComplete: Bool { isUsernameValid == .valid }
    var isDisplayNameComplete: Bool { !displayName.trimTrailingWhiteSpaces().isEmpty }

    var canCreateAccount: Bool {
        isUsernameComplete && isDisplayNameComplete
    }

    /// Whether the bottom button is enabled on the step being shown. Each step gates on its own
    /// answers, so the user is stopped where the problem is rather than at the end.
    var canAdvance: Bool {
        switch step {
        case .details:
            return isUsernameComplete && isDisplayNameComplete
        case .profile, .body:
            return true
        case .review:
            return canCreateAccount
        }
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

    // MARK: - Navigation

    @MainActor
    func advance() {
        if step == .review {
            createAccount()
        } else if let next = step.next {
            step = next
        }
    }

    func goBack() {
        if let previous = step.previous {
            step = previous
        }
    }

    // MARK: - Username

    /// Debounced rather than `.dropFirst(4)`, which is what this used to be: dropping the first four
    /// published values meant a username typed to exactly three characters and left alone was never
    /// checked at all, so it sat on `.idle` and `canCreateAccount` blocked forever.
    func usernameListener() {
        $username
            .dropFirst()
            .removeDuplicates()
            .debounce(for: .milliseconds(400), scheduler: RunLoop.main)
            .sink { [weak self] in self?.checkUsername($0) }
            .store(in: &subscriptions)
    }

    func checkUsername(_ text: String) {
        let usernameRegEx = "[a-z0-9_.]{3,50}$"
        let usernamePred = NSPredicate(format: "SELF MATCHES %@", usernameRegEx)

        guard usernamePred.evaluate(with: text) else {
            if text.isEmpty {
                isUsernameValid = .idle
            } else if text.count < 3 {
                isUsernameValid = .tooShort
            } else {
                isUsernameValid = .invalid
            }
            return
        }

        isUsernameValid = .checking
        Task { @MainActor in
            do {
                isUsernameValid = try await usernameChecker.isUsernameAvailable(text) ? .valid : .taken
            } catch {
                // A failed lookup is not a taken username. Saying "taken" for a name that is
                // probably free sends the user off to invent another one for no reason, so this
                // reports the lookup itself as the thing that failed.
                print(String(describing: error))
                isUsernameValid = .unchecked
            }
        }
    }

    // MARK: - Creation

    @MainActor
    func createAccount() {
        creationError = nil
        usernameError = nil
        uploading = true

        let newAccountModel = CreateAccountModel(
            uid: uid,
            email: email,
            username: username.trimTrailingWhiteSpaces(),
            displayName: displayName.trimTrailingWhiteSpaces(),
            bio: bio.trimTrailingWhiteSpaces(),
            heightCentimetres: heightCentimetres,
            weightKilograms: weightKilograms,
            heightUnit: heightCentimetres == nil ? nil : heightUnit,
            weightUnit: weightKilograms == nil ? nil : weightUnit,
            dateOfBirth: dateOfBirth
        )

        Task {
            do {
                try await usernameReserver.reserveUsername(newAccountModel.username, for: uid)
            } catch {
                // The username went between the availability check and here. Send the user back to
                // the field rather than clearing it — clearing loses what they typed and never says
                // why.
                print(String(describing: error))
                uploading = false
                isUsernameValid = .taken
                usernameError = "That username was taken just before we could save it. Try another."
                step = .details
                return
            }

            do {
                try await accountCreator.createAccount(newAccountModel)
            } catch {
                print(String(describing: error))
                uploading = false
                creationError = "We couldn't create your account. Check your connection and try again."
                return
            }

            if profileImage != nil {
                uploadProfileImage()
            }
            onAccountCreated()
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
