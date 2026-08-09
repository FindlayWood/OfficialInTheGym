//
//  ProfileImageUploader.swift
//  AccountCreationKit
//
//  Created by Findlay Wood on 09/08/2026.
//

import Foundation

public protocol ProfileImageUploader {
    func uploadProfileImage(_ data: Data, for uid: String) async throws
}
