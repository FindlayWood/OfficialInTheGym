//
//  CurrentUserManager.swift
//  InTheGym
//
//  Created by Findlay Wood on 24/09/2022.
//  Copyright © 2022 FindlayWood. All rights reserved.
//

import Foundation

class CurrentUserManager: MainCurrentUserService {
    @Published var currentUser: Users = Users.nilUser
    static let shared = CurrentUserManager()
    private init() {}
    
    func launch() {
        // check for current user in file manager
        do {
            let currentUserData = try Data(contentsOf: FileManager.FileManagerPaths.currentUserPath)
            let currentUserModel = try JSONDecoder().decode(Users.self, from: currentUserData)
            currentUser = currentUserModel
        } catch {
            print(String(describing: error))
        }
    }
    func storeCurrentUser(_ model: Users) {
        currentUser = model
        do {
            let encodedModel = try JSONEncoder().encode(model)
            try encodedModel.write(to: FileManager.FileManagerPaths.currentUserPath, options: [.atomic, .completeFileProtection])
        } catch {
            print(String(describing: error))
        }
    }
}

protocol MainCurrentUserService {
    var currentUser: Users { get }
    func launch()
    func storeCurrentUser(_ model: Users)
}
