//
//  File.swift
//  
//
//  Created by Findlay-Personal on 03/04/2023.
//

import Foundation
import UIKit

public class Boundary {
    
    var coordinator: Coordinator?
    
    public init(navigationController: UINavigationController, apiService: NetworkService, colour: UIColor, title: String, image: UIImage) {
        coordinator = .init(navigationController: navigationController, networkService: apiService, colour: colour, title: title, image: image)
    }
    
    public func compose() {
        coordinator?.start()
    }
}

public protocol NetworkService {
    func login(with email: String, password: String) async throws
    func signup(with email: String, password: String) async throws
    func forgotPassword(for email: String) async throws
}

class MockNetworkService: NetworkService {
    
    static let shared = MockNetworkService()
    
    private init() {}
    
    func login(with email: String, password: String) async throws {
        print("logging in...")
    }
    func signup(with email: String, password: String) async throws {
        print("signing up...")
    }
    func forgotPassword(for email: String) async {
        print("forgot password...")
    }
}
