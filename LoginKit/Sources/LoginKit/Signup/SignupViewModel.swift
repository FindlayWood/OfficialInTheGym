//
//  File.swift
//  
//
//  Created by Findlay-Personal on 03/04/2023.
//

import Combine
import Foundation

class SignupViewModel: ObservableObject {
    
    // MARK: - Published Properties
    @Published var email: String = ""
    @Published var password: String = ""
    
    @Published var isEmailValid: Bool = false
    @Published var isPasswordValid: Bool = false
    
    @Published var canSignup: Bool = false
    
    @Published var isLoading: Bool = false
    
    @Published var error: Error?
    
    @Published var emailInUse: Bool = false
    
    var subscriptions = Set<AnyCancellable>()
    
    var networkService: NetworkService
    
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
                self.canSignup = self.emailChecker(email) && self.passwordChecker(password)
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
    func signup() async {
        error = nil
        emailInUse = false
        isLoading = true
        do {
            try await networkService.signup(with: email, password: password)
            completion()
        }
        catch {
            print(String(describing: error))
            isLoading = false
            let error = error as NSError
            switch error.code {
            case 17007:
                self.emailInUse = true
            default:
                self.error = error
            }
        }
    }
}
