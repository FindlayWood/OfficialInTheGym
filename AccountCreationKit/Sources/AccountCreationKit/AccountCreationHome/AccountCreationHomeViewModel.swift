//
//  File.swift
//  
//
//  Created by Findlay-Personal on 08/04/2023.
//

import Combine
import UIKit

class AccountCreationHomeViewModel: ObservableObject {
    
    @Published var page: Int = 0
    
    var email: String
    var uid: String
    
    @Published var username: String = "" {
        didSet {
            if username.count > usernameLimit && oldValue.count <= usernameLimit {
                username = oldValue
            }
        }
    }
    @Published var isUsernameValid: UsernameValid = .idle
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
    
    private var subscriptions = Set<AnyCancellable>()
    
    var apiService: NetworkService
    
    init(apiService: NetworkService = MockNetworkService.shared, email: String, uid: String) {
        self.apiService = apiService
        self.email = email
        self.uid = uid
        usernameListener()
    }
    
    func usernameListener() {
        $username
            .dropFirst(4)
            .sink { [weak self] in self?.checkUsername($0) }
            .store(in: &subscriptions)
    }
    
    func checkUsername(_ text: String) {
        isUsernameValid = .checking
        if text.count < 3 {
            isUsernameValid = .tooShort
        } else {
            Task { @MainActor in
                do {
                    let exists = try await apiService.checkExistence(at: "Usernames/\(text)")
                    isUsernameValid = exists ? .taken : .valid
                } catch {
                    print(String(describing: error))
                }
            }
        }
    }
    @MainActor
    func createAccount() {
        uploading = true
        guard let selectedAccountType else {return}
        let newAccountModel = CreateAccountModel(uid: uid,
                                                 email: email,
                                                 username: username.trimTrailingWhiteSpaces(),
                                                 displayName: displayName.trimTrailingWhiteSpaces(),
                                                 bio: bio.trimTrailingWhiteSpaces(),
                                                 accountType: selectedAccountType)
        
        Task {
            do {
                try await apiService.upload(data: newAccountModel, at: "Users/\(uid)")
                try await apiService.uploadRealtime(data: true, at: "Usernames/\(username)")
                if profileImage != nil {
                    uploadProfileImage()
                } else {
                    uploading = false
                }
            } catch {
                print(String(describing: error))
                uploading = false
            }
        }
    }
    func uploadProfileImage() {
        guard let data = profileImage?.jpegData(compressionQuality: 0.1) else {return}
        Task {
            do {
                try await apiService.dataUpload(data: data, at: "")
                uploading = false
            } catch {
                print(String(describing: error))
                uploading = false
            }
        }
    }
    func signOutAction() {
        Task {
            do {
                try await apiService.signout()
            } catch {
                print(String(describing: error))
            }
        }
    }
}

enum AccountType: String, CaseIterable, Identifiable, Codable {
    var id: String {
        title
    }
    
    case individual
    case athlete
    case coach
    
    var title: String {
        switch self {
        case .individual:
            return "Individual"
        case .athlete:
            return "Athlete"
        case .coach:
            return "Coach"
        }
    }
    
    var message: String {
        switch self {
        case .individual:
            return "Select this type if you are looking to use this app as an individual."
        case .athlete:
            return "Select this type if you are an athlete playing sport, part of a team"
        case .coach:
            return "Select this type if you are looking to manage teams, athlete's or clients."
        }
    }
}

enum UsernameValid {
    case idle
    case tooShort
    case checking
    case taken
    case valid
    case invalid
}

struct CreateAccountModel: Codable {
    var uid: String
    var email: String
    var username: String
    var displayName: String
    var bio: String
    var accountType: AccountType
    var createdDate: Date = .now
    var verifiedAccount: Bool = false
    var eliteAccount: Bool = false
}