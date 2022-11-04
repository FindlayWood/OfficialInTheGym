//
//  LoginViewModel.swift
//  InTheGym
//
//  Created by Findlay Wood on 11/11/2021.
//  Copyright © 2021 FindlayWood. All rights reserved.
//

import Foundation
import Combine
import Firebase
import FirebaseMessaging

class LoginViewModel {
    
    // MARK: - Published Properties
    @Published var email: String = ""
    @Published var password: String = ""
    
    @Published var isEmailValid: Bool = false
    @Published var isPasswordValid: Bool = false
    
    @Published var canLogin: Bool = false
    
    @Published var isLoading: Bool = false
    
    var subscriptions = Set<AnyCancellable>()
    
    //MARK: - Action Related Publishers
    var userSuccessfullyLoggedIn = PassthroughSubject<Users, Never>()
    var errorWhenLogginIn = PassthroughSubject<loginError, Never>()
    var resendEmailVerificationReturned = PassthroughSubject<Bool,Never>()
    
    // MARK: - Private Properties
    private var loginModel = LoginModel()
    
    private var apiService: AuthManagerService
    
    // MARK: - Email Regex
    let emailPredicate = NSPredicate(format: "SELF MATCHES %@", "[A-Z0-9a-z._%+-]+@[A-Za-z0-9.-]+\\.[A-Za-z]{2,64}")
    
    // MARK: - Initializer
    init(apiService: AuthManagerService = FirebaseAuthManager.shared) {
        self.apiService = apiService
        
        $email
            .map { [unowned self] email in
                self.loginModel.email = email
                return self.emailPredicate.evaluate(with: email)
            }
            .sink { [unowned self] emailValid in
                self.isEmailValid = emailValid
            }
            .store(in: &subscriptions)
        
        $password
            .map { [unowned self] password in
                self.loginModel.password = password
                return password.count > 5
            }
            .sink { [unowned self] passwordValid in
                self.isPasswordValid = passwordValid
            }
            .store(in: &subscriptions)
        
        Publishers.CombineLatest($isEmailValid, $isPasswordValid)
            .map { isEmailValid, isPasswordValid in
                return isEmailValid && isPasswordValid
            }
            .sink { [unowned self] loginValid in
                self.canLogin = loginValid
            }
            .store(in: &subscriptions)
  
    }
    
    // MARK: - Login Function
    @MainActor
    func login() async {
        isLoading = true
        do {
            let userModel = try await apiService.loginAsync(with: loginModel)
            userSuccessfullyLoggedIn.send(userModel)
            isLoading = false
            await updateFCMToken()
        } catch {
            let error = error as NSError
            switch error.code {
            case AuthErrorCode.userNotFound.rawValue:
                self.errorWhenLogginIn.send(.invalidCredentials)
            case AuthErrorCode.invalidEmail.rawValue:
                self.errorWhenLogginIn.send(.invalidCredentials)
            default:
                self.errorWhenLogginIn.send(.unKnown)
            }
        }
        
        apiService.loginUser(with: loginModel) { [weak self] result in
            guard let self = self else {return}
            switch result {
            case .success(let user):
                self.userSuccessfullyLoggedIn.send(user)
                self.isLoading = false
                Task {
                    await self.updateFCMToken()
                }
            case .failure(let error):
                self.errorWhenLogginIn.send(error)
                self.isLoading = false
            }
        }
    }
    
    func updateFCMToken() async {
        do {
            let fcmToken = try await Messaging.messaging().token()
            let tokenModel = FCMTokenModel(fcmToken: fcmToken, tokenUpdatedDate: .now)
            try await FirestoreManager.shared.upload(tokenModel)
            print(fcmToken)
        } catch {
            print(String(describing: error))
        }
    }

    
    // MARK: - Actions
    
    func resendEmailVerification(to user: User) {
        apiService.resendEmailVerification(to: user) { [weak self] sent in
            guard let self = self else {return}
            self.resendEmailVerificationReturned.send(sent)
        }
    }
    
    func updateEmail(with newValue: String) {
        loginModel.email = newValue
        email = newValue
    }
    
    func updatePassword(with newValue: String) {
        loginModel.password = newValue
        password = newValue
    }
}

struct LoginModel {
    var email: String = ""
    var password: String = ""
}
