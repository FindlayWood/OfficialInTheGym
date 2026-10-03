//
//  ProfileEditSpy.swift
//  ProfileKitTests
//
//  Created by Findlay Wood on 03/10/2026.
//

import UIKit
@testable import ProfileKit

/// Both Edit Profile writes in one message log, so a test can assert their
/// order: the photo goes before the text. The errors are settable, so a test
/// can fail one attempt and let the retry succeed. Never asserts — the test does.
final class ProfileEditSpy: ProfileDetailsWriter, ProfilePhotoUploader, @unchecked Sendable {

    enum Message: Equatable {
        case uploadPhoto
        case saveDetails(ProfileDetails)
    }

    private(set) var receivedMessages: [Message] = []
    var photoError: Error?
    var detailsError: Error?

    func upload(_ photo: UIImage) async throws {
        receivedMessages.append(.uploadPhoto)
        if let photoError { throw photoError }
    }

    func save(_ details: ProfileDetails) async throws {
        receivedMessages.append(.saveDetails(details))
        if let detailsError { throw detailsError }
    }
}
