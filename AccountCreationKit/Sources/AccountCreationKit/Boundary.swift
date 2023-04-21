//
//  File.swift
//  
//
//  Created by Findlay-Personal on 08/04/2023.
//

import UIKit

public class Boundary {
    
    var coordinator: Coordinator?
    
    public init(navigationController: UINavigationController, apiService: NetworkService, colour: UIColor, image: UIImage, email: String, uid: String) {
        coordinator = .init(navigationController: navigationController, networkService: apiService, colour: colour, image: image, email: email, uid: uid)
    }
    
    public func compose() {
        coordinator?.start()
    }
}
