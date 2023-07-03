//
//  File.swift
//  
//
//  Created by Findlay-Personal on 03/04/2023.
//

import Combine
import Foundation

class LoginViewModel: ObservableObject {
    
    // MARK: - Published Properties
    @Published var email: String = ""
    @Published var password: String = ""
    
    @Published var isEmailValid: Bool = false
    @Published var isPasswordValid: Bool = false
    
    @Published var canLogin: Bool = false
    
    @Published var isLoading: Bool = false
    
    @Published var error: Error?
    
    var subscriptions = Set<AnyCancellable>()
    
    var networkService: NetworkService
    
    var coordinator: LoginFlow?
    
    var completion: () -> Void
    
    init(networkService: NetworkService, completion: @escaping () -> Void) {
        self.networkService = networkService
        self.completion = completion
        detailsObserver()
    }
    
    func detailsObserver() {
        Publishers.CombineLatest($email, $password)
            .sink { [weak self] email, password in
                guard let self else {return}
                self.canLogin = self.emailChecker(email) && self.passwordChecker(password)
            }
            .store(in: &subscriptions)
    }
    
    func emailChecker(_ email: String) -> Bool {
        let emailRegEx = "[A-Z0-9a-z._%+-]+@[A-Za-z0-9.-]+\\.[A-Za-z]{2,64}"
        
        let emailPred = NSPredicate(format:"SELF MATCHES %@", emailRegEx)
        return emailPred.evaluate(with: email)
    }
    
    func passwordChecker(_ password: String) -> Bool {
        return password.count > 5
    }
    
    @MainActor
    func login() async {
        error = nil
        isLoading = true
        do {
            try await networkService.login(with: email, password: password)
            completion()
        } catch {
            print(String(describing: error))
            self.error = error
            isLoading = false
        }
    }
    func forgotPasswordAction() {
        coordinator?.forgotPassword()
    }
}
