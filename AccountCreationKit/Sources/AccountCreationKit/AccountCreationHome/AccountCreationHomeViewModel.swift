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
    
    var createdCallback: () -> Void
    var signOutCallback: () -> Void
    
    var apiService: NetworkService
    
    init(apiService: NetworkService = MockNetworkService.shared, email: String, uid: String, callback: @escaping () -> Void, signOutCallback: @escaping () -> Void) {
        self.apiService = apiService
        self.email = email
        self.uid = uid
        self.createdCallback = callback
        self.signOutCallback = signOutCallback
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
        let usernameRegEx = "[A-Za-z0-9_.]{3,50}$"
        
        let usernamePred = NSPredicate(format:"SELF MATCHES %@", usernameRegEx)
        if usernamePred.evaluate(with: text) {
            Task { @MainActor in
                do {
                    if let _: UsernameModel = try await apiService.read(at: "Usernames/\(text)") {
                        isUsernameValid = .taken
                    } else {
                        isUsernameValid = .valid
                    }
                } catch {
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
            let uploadedUsername = await uploadUsername()
            if uploadedUsername {
                do {
                    try await apiService.callFunction(named: "createAccount", with: newAccountModel.toJSONData())
                    if profileImage != nil {
                        uploadProfileImage()
                    }
                    createdCallback()
                } catch {
                    // failed to upload account
                    print(String(describing: error))
                    uploading = false
                }
                // carry on with upload of account
            } else {
                // error with username already being taken
                username.removeAll()
                uploading = false
            }
        }
    }
    func uploadUsername() async -> Bool {
        do {
            let usernameModel = UsernameModel(username: username, uid: uid)
            try await apiService.upload(data: usernameModel, at: "Usernames/\(username)")
            print("success")
            return true
        } catch {
            print("error uploading username")
            print(String(describing: error))
            return false
        }
    }
    func uploadProfileImage() {
        guard let data = profileImage?.jpegData(compressionQuality: 0.1) else {return}
        Task {
            do {
                try await apiService.dataUpload(data: data, at: "ProfilePhotos/\(uid)")
            } catch {
                print(String(describing: error))
            }
        }
    }
    func signOutAction() {
        Task {
            do {
                try await apiService.signout()
                signOutCallback()
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
            return "Select this type if you are an athlete playing sport / part of a team"
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
    var isPrivate: Bool = false
}

extension CreateAccountModel {
    func toJSONData() -> [String: Any] {
        var data: [String: Any] = [String:Any]()
        data["username"] = username
        data["displayName"] = displayName
        data["bio"] = bio
        data["accountType"] = accountType.rawValue
        data["isPrivate"] = isPrivate
        return data
    }
}

struct UsernameModel: Codable {
    var username: String
    var uid: String
    var dateTaken: Date = .now
}
