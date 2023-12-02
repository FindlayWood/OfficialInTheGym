//
//  File.swift
//  
//
//  Created by Findlay-Personal on 10/05/2023.
//

import Foundation

public protocol CurrentUserService {
    var currentUserUID: String { get }
}

struct PreviewCurrentUserService: CurrentUserService {
    var currentUserUID: String = "previewUID"
}
