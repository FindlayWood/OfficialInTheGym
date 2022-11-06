//
//  SignUpViewModel.swift
//  InTheGym
//
//  Created by Findlay Wood on 16/04/2021.
//  Copyright © 2021 FindlayWood. All rights reserved.
//

import Foundation
import Firebase
import Combine


enum SignUpValidationState {
    case Valid
    case InValid(SignUpError)
}
enum SignUpError: String, Error {
    case fillAllFields = "Please fill in all fields."
    case invalidEmail = "Please use a valid email."
    case emailTaken = "An account with this email is already in use."
    case takenUsername = "An account with this username is already in use."
    case passwordsDoNotMatch = "Passwords do not match."
    case passwordTooShort = "Password is too short. Passwords must be at least six characters long."
    case unknown = "There was en error. Please try again."
}

typealias successClosure = ((String) -> Void)?
typealias failedClosure = ((SignUpError) -> Void)?

class SignUpViewModel: ObservableObject {
    
    @Published var isLoading = false
    
    // MARK: - Combine Varibles
    @Published var email: String = ""
    @Published var username: String = ""
    @Published var firstName: String = ""
    @Published var lastName: String = ""
    @Published var password: String = ""
    
    @Published var emailValid: SignUpValidState = .notEnoughInfo
    @Published var usernameValid: SignUpValidState = .notEnoughInfo
    @Published var firstNameValid: Bool = false
    @Published var lastNameValid: Bool = false
    @Published var passwordValid: SignUpValidState = .notEnoughInfo
    
    @Published var namesValid: Bool = false
    @Published var userInfoValid: Bool = false
    
    @Published var canSignUp: Bool = false
    
    var subscriptions = Set<AnyCancellable>()
    
    var successfullyCreatedAccount = PassthroughSubject<String,Never>()
    var errorCreatingAccount = PassthroughSubject<SignUpError,Never>()
    
    var SignUpSuccesfulClosure: ((String)->())?
    var SignUpFailedClosure: ((SignUpError)->())?
    private(set) var minimumPasswordLength = 6
    private var user = SignUpUserModel()
    
//    var email: String {
//        return user.email
//    }
//    var username: String {
//        return user.username
//    }
//    var firstName: String {
//        return user.firstName
//    }
//    var lastName: String {
//        return user.lastName
//    }
//    var password: String {
//        return user.password
//    }
    var confirmPassword: String {
        return user.confirmPassword
    }
    var admin: Bool {
        return user.admin
    }
    
    var apiService: AuthManagerService
    
    // MARK: - Email Regex
    let emailPredicate = NSPredicate(format: "SELF MATCHES %@", "[A-Z0-9a-z._%+-]+@[A-Za-z0-9.-]+\\.[A-Za-z]{2,64}")
    
    // MARK: - Initializer
    init(apiService: AuthManagerService = FirebaseAuthManager.shared) {
        self.apiService = apiService
        setUpSubscriptions()
    }
    
    // MARK: - Actions
    @MainActor
    func signUpButtonPressed() {
        isLoading = true
        Task {
            do {
                try await apiService.createNewUserAsync(with: self.user)
                self.successfullyCreatedAccount.send(self.user.email)
                isLoading = false
            } catch {
                isLoading = false
                let error = error as NSError
                switch error.code {
                case AuthErrorCode.emailAlreadyInUse.rawValue:
                    errorCreatingAccount.send(.emailTaken)
                case AuthErrorCode.invalidEmail.rawValue:
                    errorCreatingAccount.send(.invalidEmail)
                default:
                    errorCreatingAccount.send(.unknown)
                }
            }
        }
//        apiService.createNewUser(with: self.user) { [weak self] result in
//            guard let self = self else {return}
//            switch result {
//            case .success(_):
//                self.successfullyCreatedAccount.send(self.user.email)
//            case .failure(let error):
//                self.errorCreatingAccount.send(error)
//                //print(error.localizedDescription)
//            }
//        }
    }
    
    // MARK: - Subscriptions
    func setUpSubscriptions() {
        $firstName
            .sink { [weak self] in self?.user.firstName = $0 }
            .store(in: &subscriptions)
        $lastName
            .sink { [weak self] in self?.user.lastName = $0 }
            .store(in: &subscriptions)
        $email
            .sink { [weak self] in self?.user.email = $0 }
            .store(in: &subscriptions)
        $username
            .sink { [weak self] in self?.user.username = $0 }
            .store(in: &subscriptions)
        $password
            .sink { [weak self] in self?.user.password = $0 }
            .store(in: &subscriptions)
        
        $firstName
            .map { newName in
                return newName.count > 0
            }
            .sink { newNameValid in
                self.firstNameValid = newNameValid
            }
            .store(in: &subscriptions)
        
        $lastName
            .map { newName in
                return newName.count > 0
            }
            .sink { newNameValid in
                self.lastNameValid = newNameValid
            }
            .store(in: &subscriptions)
        
        $email
            .map { [unowned self] email in
                if self.emailPredicate.evaluate(with: email) && email.count > 5 {
                    return .valid
                } else if email.count > 5 {
                    return .inValidInfo
                } else {
                    return .notEnoughInfo
                }
            }
            .sink { newEmailValid in
                self.emailValid = newEmailValid
            }
            .store(in: &subscriptions)
        
        $username
            .removeDuplicates()
            .sink { [unowned self] username in
                if username.count < 3 {
                    self.usernameValid = .notEnoughInfo
                } else {
                    self.usernameValid = .checking
                }
            }
            .store(in: &subscriptions)
        
        $username
            .filter { $0.count > 2 }
            .removeDuplicates()
            .debounce(for: 0.5, scheduler: RunLoop.main)
            .map { [unowned self] newUsername -> AnyPublisher<SignUpValidState, Never> in
                self.checkUsername(for: newUsername)
                    .eraseToAnyPublisher()
            }
            .switchToLatest()
            .sink { [weak self] newState in
                guard let self = self else {return}
                self.usernameValid = newState
            }
            .store(in: &subscriptions)
        
        $password
            .filter { $0.count > 0 }
            .map { password -> SignUpValidState in
                if password.count > 5 {
                    return .valid
                } else {
                    return .inValidInfo
                }
            }
            .sink { [weak self] newPasswordValid in
                guard let self = self else {return}
                self.passwordValid = newPasswordValid
            }
            .store(in: &subscriptions)
        
        
        Publishers.CombineLatest($emailValid, $passwordValid)
            .map { emailValid, passwordValid in
                return emailValid == .valid && passwordValid == .valid
            }
            .sink { halfValid in
                self.userInfoValid = halfValid
            }
            .store(in: &subscriptions)
        
        Publishers.CombineLatest($firstNameValid, $lastNameValid)
            .map { firstNameValid, lastNameValid in
                return firstNameValid && lastNameValid
            }
            .sink { namesAreValid in
                self.namesValid = namesAreValid
            }
            .store(in: &subscriptions)
        
        
        Publishers.CombineLatest3($namesValid, $userInfoValid, $usernameValid)
            .map { namesValid, userInfoValid, usernameValid in
                return namesValid && userInfoValid && (usernameValid == .valid)
            }
            .sink { userCanSignUp in
                self.canSignUp = userCanSignUp
            }
            .store(in: &subscriptions)
        
        
    }
    
    func checkUsername(for username: String) -> Future<SignUpValidState, Never> {
        Future { [weak self] promise in
            guard let self = self else {return}
            self.apiService.checkUsernameIsUnique(for: username) { unique in
                if unique {
                    promise(.success(.valid))
                } else {
                    promise(.success(.inValidInfo))
                }
            }
        }
    }
    
    //MARK: - Checking username is unique
//    func checkUsernameIsUnique(for username:String, completion: @escaping (Bool) -> ()) {
//        let ref = Database.database().reference().child("Usernames").child(username)
//        ref.observeSingleEvent(of: .value) { (snapshot) in
//            if snapshot.exists(){
//                completion(false)
//            } else {
//                completion(true)
//            }
//        }
//    }
    
    //MARK: - Checking all fields are valid
//    func loginAttempt() {
//        switch validate(){
//        case .InValid(let errorMessage):
//            print(errorMessage)
//            self.SignUpFailedClosure?(errorMessage)
//        case .Valid:
//            checkUsernameIsUnique(for: user.username) { (unique) in
//                if unique {
//                    self.tryToSignUp()
//                } else {
//                    self.SignUpFailedClosure?(.takenUsername)
//                }
//            }
//        }
//    }
    
//    func tryToSignUp() {
//        Auth.auth().createUser(withEmail: user.email, password: user.password) { (signedUpUser, error) in
//            if let error = error {
//                let error = error as NSError
//                switch error.code {
//                case AuthErrorCode.emailAlreadyInUse.rawValue:
//                    self.SignUpFailedClosure?(.emailTaken)
//                case AuthErrorCode.invalidEmail.rawValue:
//                    self.SignUpFailedClosure?(.invalidEmail)
//                case AuthErrorCode.weakPassword.rawValue:
//                    self.SignUpFailedClosure?(.passwordTooShort)
//                default:
//                    self.SignUpFailedClosure?(.unknown)
//                    print("unknown error \(error.localizedDescription)")
//                }
//            } else {
//                //succes
//
//                let userID = Auth.auth().currentUser!.uid
//                let user = Auth.auth().currentUser!
//
//                user.sendEmailVerification()
//
//                let userData = ["email":self.user.email,
//                                "username":self.user.username,
//                                "admin":self.user.admin!,
//                                "firstName":self.user.firstName,
//                                "lastName":self.user.lastName,
//                                "uid":userID] as [String : Any]
//
//                let userRef = Database.database().reference().child("users").child(userID)
//                userRef.setValue(userData)
//
//                let actData = ["time":ServerValue.timestamp(),
//                               "message":"\(self.user.username), welcome to InTheGym!",
//                               "type":"Account Created",
//                               "posterID":userID,
//                               "isPrivate":true] as [String:AnyObject]
//
//                let postSelfReferences = Database.database().reference().child("PostSelfReferences").child(userID)
//                let postRef = Database.database().reference().child("Posts").childByAutoId()
//                let postKey = postRef.key!
//                let timelineRef = Database.database().reference().child("Timeline").child(userID)
//                let usernamesRef = Database.database().reference().child("Usernames")
//
//                postRef.setValue(actData)
//                postSelfReferences.child(postKey).setValue(true)
//                timelineRef.child(postKey).setValue(true)
//                usernamesRef.child(self.user.username).setValue(true)
//                FirebaseAPI.shared().uploadActivity(with: .AccountCreated)
//
//                self.SignUpSuccesfulClosure?(self.user.email)
//            }
//        }
//    }
    
    
    
}

// MARK: - Update user attributes
extension SignUpViewModel {
    func updateEmail(with email:String) {
        user.email = email
        self.email = email
    }
    func updateFirstName(with name:String) {
        user.firstName = name
        self.firstName = name
    }
    func updateLastName(with name:String) {
        user.lastName = name
        self.lastName = name
    }
    func updateUsername(with username:String) {
        user.username = username
        self.username = username
    }
    func updatePassword(with password:String) {
        user.password = password
        self.password = password
    }
//    func updateConfirmPassword(with password:String) {
//        user.confirmPassword = password
//    }
    func updateAdmin(with admin:Bool) {
        user.admin = admin
    }
    func resetFields() {
        self.email = ""
        self.firstName = ""
        self.lastName = ""
        self.username = ""
        self.password = ""
    }
}

//MARK: - Validate Sign Up Attempt
extension SignUpViewModel {
    func validate() -> SignUpValidationState {
        if user.email.isEmpty || user.firstName.isEmpty || user.lastName.isEmpty || user.username.isEmpty || user.password.isEmpty || user.confirmPassword.isEmpty{
            return .InValid(.fillAllFields)
        }
        if user.password.count < minimumPasswordLength || user.confirmPassword.count < minimumPasswordLength {
            return .InValid(.passwordTooShort)
        }
        if user.password != user.confirmPassword {
            return .InValid(.passwordsDoNotMatch)
        }
        return .Valid
    }
}
