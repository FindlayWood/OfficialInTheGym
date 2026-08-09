//
//  File.swift
//  
//
//  Created by Findlay-Personal on 04/04/2023.
//

import Combine
import Foundation

class ForgotPasswordViewModel: ObservableObject {
    
    // MARK: - Published Properties
    @Published var email: String = ""
    
    @Published var isEmailValid: Bool = false
    
    @Published var canReset: Bool = false
    
    @Published var isLoading: Bool = false
    
    var subscriptions = Set<AnyCancellable>()
    
    var networkService: NetworkService
    
    init(networkService: NetworkService) {
        self.networkService = networkService
        detailsObserver()
    }
    
    func detailsObserver() {
        $email
            .sink { [weak self] email in
                guard let self else {return}
                self.canReset = self.emailChecker(email)
            }
            .store(in: &subscriptions)
    }
    
    func emailChecker(_ email: String) -> Bool {
        let emailRegEx = "[A-Z0-9a-z._%+-]+@[A-Za-z0-9.-]+\\.[A-Za-z]{2,64}"
        
        let emailPred = NSPredicate(format:"SELF MATCHES %@", emailRegEx)
        return emailPred.evaluate(with: email)
    }
    
    @MainActor
    func login() async {
        isLoading = true
        do {
            try await networkService.forgotPassword(for: email)
            isLoading = false
        }
        catch {
            print(String(describing: error))
            isLoading = false
        }
    }
}
