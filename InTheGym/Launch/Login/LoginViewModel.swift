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

class LoginViewModel {
    
    // MARK: - Published Properties
    @Published var email: String = ""
    @Published var password: String = ""
    
    @Published var isEmailValid: Bool = false
    @Published var isPasswordValid: Bool = false
    
    @Published var canLogin: Bool = false
    
    var subscriptions = Set<AnyCancellable>()
    
    //MARK: - Action Related Publishers
    var loginButtonTapped = PassthroughSubject<LoginModel, loginError>()
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
        
        // MARK: - Watching for login attempts
        if #available(iOS 14.0, *) {
            loginButtonTapped
                .flatMap ({ [unowned self] newLoginModel -> AnyPublisher<Result<Users, loginError>, Never> in
                    self.loginUser(with: newLoginModel)
                        .map { result in
                            switch result {
                            case .success(let user):
                                return .success(user)
                            case .failure(let error):
                                return .failure(error)
                            }
                        }
                        .eraseToAnyPublisher()
                })
            //            .flatMap { [unowned self] newLoginModel -> AnyPublisher<Result<Users,loginError>, Never> in
            //                self.loginUser(with: newLoginModel)
            //                    .map { result in
            //                        switch result {
            //                        case .success(let user):
            //                            return .success(user)
            //                        case .failure(let error):
            //                            return .failure(error)
            //                        }
            //
            //                    }
            ////                    .mapError { [unowned self] error -> loginError in
            ////                        print("there was an error here...")
            ////                        self.errorWhenLogginIn.send(error)
            ////                        return error
            ////                    }
            //                    .eraseToAnyPublisher()
            //            }
                .sink { error in
                    print(error)
                } receiveValue: { [unowned self] newLoggedInUser in
                    switch newLoggedInUser {
                    case .success(let user):
                        self.userSuccessfullyLoggedIn.send(user)
                    case .failure(let error):
                        self.errorWhenLogginIn.send(error)
                    }
                    //self.userSuccessfullyLoggedIn.send(newLoggedInUser)
                }
                .store(in: &subscriptions)
        } else {
            // Fallback on earlier versions
        }


        
    }
    
    // MARK: - Login Function
    func attemptToLogin() {
        apiService.loginUser(with: loginModel) { result in
            switch result {
            case .success(let user):
                print("user loggen in \(user.username)")
            case .failure(let error):
                switch error {
                case .invalidCredentials:
                    print("invalid credentials")
                case .emailNotVerified:
                    print("email not verified")
                case .unKnown:
                    print("unknown")
                }
            }
        }
    }
    
    func loginUser(with model: LoginModel) -> AnyPublisher<Result<Users, loginError>, Never> {
        Future { [unowned self] promise in
            self.apiService.loginUser(with: model) { result in
                switch result {
                case .success(let user):
                    print("promise successful")
                    promise(.success(.success(user)))
                case .failure(let error):
                    promise(.success(.failure(error)))
                }
            }
        }.eraseToAnyPublisher()
    }
    
    // MARK: - Actions
    func loginButtonAction() {
        if canLogin {
            loginButtonTapped.send(loginModel)
        }
    }
    
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
