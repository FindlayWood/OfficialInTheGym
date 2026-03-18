//
//  File.swift
//  
//
//  Created by Findlay-Personal on 10/05/2023.
//

import Foundation

protocol BaseFactory {
    var networkService: NetworkService { get }
    var userService: CurrentUserService { get }
}
