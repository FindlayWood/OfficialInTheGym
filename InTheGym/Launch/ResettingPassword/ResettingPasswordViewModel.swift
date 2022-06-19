//
//  ResettingPasswordViewModel.swift
//  InTheGym
//
//  Created by Findlay Wood on 23/11/2021.
//  Copyright © 2021 FindlayWood. All rights reserved.
//

import Foundation
import Combine

class ResettingPasswordViewModel {
    // MARK: - Published Properties
    @Published var email: String = ""
    @Published var isEmailValid: Bool = false
    private var subscriptions = Set<AnyCancellable>()
    //MARK: - Action Related Publishers
    var sendButtonTapped = PassthroughSubject<String, Never>()
    var emailSentSuccessfully = PassthroughSubject<Bool, Never>()
    // MARK: - Email Regex
    let emailPredicate = NSPredicate(format: "SELF MATCHES %@", "[A-Z0-9a-z._%+-]+@[A-Za-z0-9.-]+\\.[A-Za-z]{2,64}")
    // MARK: - Private Properties
    private var apiService: AuthManagerService
    var navigationTitle: String = "Reset Password"
    // MARK: - Initializer
    init(apiService: AuthManagerService = FirebaseAuthManager.shared) {
        self.apiService = apiService
        startSubscriptions()
    }
    // MARK: - Combine Subscriptions
    func startSubscriptions() {
        $email
            .map { [unowned self] email in
                return self.emailPredicate.evaluate(with: email)
            }
            .sink { [unowned self] emailValid in
                self.isEmailValid = emailValid
            }
            .store(in: &subscriptions)
        
        sendButtonTapped
            .map { emailString -> AnyPublisher<Bool, Never> in
                self.sendEmail(to: emailString)
                    .map { successful in
                        return successful
                    }
                    .eraseToAnyPublisher()
            }
            .switchToLatest()
            .sink { error in
                print(error)
            } receiveValue: { [unowned self] successful in
                self.emailSentSuccessfully.send(successful)
            }
            .store(in: &subscriptions)

    }
    // MARK: - Actions
    func sendButtonAction() {
        sendButtonTapped.send(email)
    }
    // MARK: - API Call
    func sendEmail(to email: String) -> AnyPublisher<Bool, Never> {
        Future { [weak self] promise in
            guard let self = self else {return}
            self.apiService.sendResetPassword(to: email) { successful in
                if successful {
                    promise(.success(true))
                } else {
                    promise(.success(false))
                }
            }
        }.eraseToAnyPublisher()
    }
    // MARK: - Update
    func updateEmail(with newValue: String) {
        email = newValue
    }
}
