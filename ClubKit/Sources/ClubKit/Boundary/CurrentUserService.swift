//
//  File.swift
//  
//
//  Created by Findlay-Personal on 10/05/2023.
//

import Foundation

public protocol CurrentUserService {
    var currentUserUID: String { get }
    var displayName: String { get }
    var username: String { get }
}

struct PreviewCurrentUserService: CurrentUserService {
    var currentUserUID: String = "previewUID"
    var displayName: String = "Preview"
    var username: String = "preview"
}
