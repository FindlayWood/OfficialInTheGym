//
//  File.swift
//  
//
//  Created by Findlay-Personal on 08/04/2023.
//

import UIKit

public class Boundary {
    
    var coordinator: Coordinator?
    
    public init(navigationController: UINavigationController, apiService: NetworkService, colour: UIColor, email: String, uid: String, callback: @escaping () -> Void, signOut: @escaping () -> Void) {
        coordinator = .init(navigationController: navigationController, networkService: apiService, colour: colour, email: email, uid: uid, callback: callback, signOutCallback: signOut)
    }
    
    public func compose() {
        coordinator?.start()
    }
}
