//
//  FileManager+Extension.swift
//  InTheGym
//
//  Created by Findlay Wood on 25/09/2022.
//  Copyright © 2022 FindlayWood. All rights reserved.
//

import Foundation

extension FileManager {
    
    static var documentsDirectory: URL {
        let paths = self.default.urls(for: .documentDirectory, in: .userDomainMask)
        return paths[0]
    }
    
    enum FileManagerPaths {
        static let currentUserPath = FileManager.documentsDirectory.appendingPathComponent(FileManagerPathComponents.currentUser)
        static let allUserProfilesPath = FileManager.documentsDirectory.appendingPathComponent(FileManagerPathComponents.allUsers)
    }
    
    enum FileManagerPathComponents {
        static let currentUser = "currentUser"
        static let allUsers = "allUserProfiles"
    }
}
