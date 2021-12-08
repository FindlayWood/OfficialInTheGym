//
//  SignUpTests.swift
//  InTheGymTests
//
//  Created by Findlay Wood on 07/12/2021.
//  Copyright © 2021 FindlayWood. All rights reserved.
//

import Foundation
@testable import InTheGym
import XCTest
import Combine

class SignUpTests: XCTestCase {
    
    var sut: SignUpViewModel!
    var mockService: MockFirebaseAuthManager!
    
    var subscriptions = Set<AnyCancellable>()
    
    override func setUp() {
        mockService = .init()
        sut = .init(apiService: mockService)
        sut.updateEmail(with: "example@.com")
    }
    
    func testSignUpButtonClickedSuccessful() {
        // Create exception for async background tasks
        let exception = XCTestExpectation(description: "Waiting for publisher to emit values.")
        
        
        sut.successfullyCreatedAccount
            .sink { result in
                XCTAssertEqual(result, "example@.com")
                exception.fulfill()
            }
            .store(in: &subscriptions)
        
        sut.signUpButtonPressed()
        
        wait(for: [exception], timeout: 5)
    }
    
    func testSignUpButtonClickedError() {
        mockService.completionResult = .failure(.unknown)
        
        let exception = XCTestExpectation(description: "Waiting for publisher to emit error")
        
        sut.errorCreatingAccount
            .sink { error in
                XCTAssertEqual(SignUpError.unknown, error)
                exception.fulfill()
            }
            .store(in: &subscriptions)
        
        sut.signUpButtonPressed()
        
        wait(for: [exception], timeout: 5)
    }
    
    func testCheckUniqueIsUsername() {
        
        mockService.usernameCompletionResult = true
        
        let exception = XCTestExpectation(description: "Checking username.")
        
        let usernameUniquePublisher = sut.checkUsername(for: "")
        
        usernameUniquePublisher
            .sink { state in
                XCTAssertEqual(SignUpValidState.valid, state)
                exception.fulfill()
            }
            .store(in: &subscriptions)
        
        
        wait(for: [exception], timeout: 5)
    }
    
    func testUsernameIsNotUnique() {
        
        mockService.usernameCompletionResult = false
        
        let exception = XCTestExpectation(description: "Checking username is not unique.")
        
        let usernamePublisher = sut.checkUsername(for: "")
        
        usernamePublisher
            .sink { state in
                XCTAssertEqual(SignUpValidState.inValidInfo, state)
                exception.fulfill()
            }
            .store(in: &subscriptions)
        
        wait(for: [exception], timeout: 5)
    }
    
    func testValidEmail() {
        
        let exception = XCTestExpectation(description: "Checking Valid Email.")
        
        sut.$email
            .dropFirst()
            .sink { [unowned self] emailString in
                XCTAssertEqual(self.sut.emailPredicate.evaluate(with: emailString), true)
                exception.fulfill()
            }
            .store(in: &subscriptions)
        
        sut.updateEmail(with: "avalidemail@example.com")
        
        wait(for: [exception], timeout: 5)
        
    }
    
    func testInvalidEmail() {
        
        let exception = XCTestExpectation(description: "Checking invalid Email.")
        
        sut.$email
            .dropFirst()
            .sink { [unowned self] emailString in
                XCTAssertEqual(self.sut.emailPredicate.evaluate(with: emailString), false)
                exception.fulfill()
            }
            .store(in: &subscriptions)
        
        sut.updateEmail(with: "invalidemailaddress.com")
        
        wait(for: [exception], timeout: 5)
    }
    
    func testValidPassword() {
        let exception = XCTestExpectation(description: "Checking valid password.")
        
        sut.$password
            .dropFirst()
            .sink { [unowned self] passwordString in
                XCTAssertEqual(passwordString.count > self.sut.minimumPasswordLength, true)
                exception.fulfill()
            }
            .store(in: &subscriptions)
        
        sut.updatePassword(with: "password")
        
        wait(for: [exception], timeout: 5)
    }
    
    func testInvalidPassword() {
        let exception = XCTestExpectation(description: "Checking invalid password")
        
        sut.$password
            .dropFirst()
            .sink { [unowned self] passwordString in
                XCTAssertEqual(passwordString.count > self.sut.minimumPasswordLength, false)
                exception.fulfill()
            }
            .store(in: &subscriptions)
        
        sut.updatePassword(with: "abc")
        
        wait(for: [exception], timeout: 5)
    }
}
