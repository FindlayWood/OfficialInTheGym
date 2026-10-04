//
//  EditProfileViewModelTests.swift
//  ProfileKitTests
//
//  Created by Findlay Wood on 03/10/2026.
//

import UIKit
import XCTest
@testable import ProfileKit

@MainActor
final class EditProfileViewModelTests: XCTestCase {

    func test_save_closesWithoutWritingWhenNothingChanged() async {
        let sut = makeSUT()

        await sut.viewModel.save()

        XCTAssertTrue(sut.spy.receivedMessages.isEmpty)
        XCTAssertEqual(sut.events, [.finished])
    }

    func test_save_writesTheTrimmedDetailsThenCloses() async {
        let sut = makeSUT()
        sut.viewModel.displayName = "  New Name  "
        sut.viewModel.bio = "\nNew bio\n"

        await sut.viewModel.save()

        XCTAssertEqual(sut.spy.receivedMessages, [.saveDetails(ProfileDetails(displayName: "New Name", bio: "New bio"))])
        XCTAssertEqual(sut.events, [.saved, .finished])
    }

    // Trailing whitespace alone is not an edit. Treating it as one would write
    // the same name back.
    func test_save_treatsWhitespaceOnlyChangesAsNoChange() async {
        let sut = makeSUT()
        sut.viewModel.displayName = "Display Name "

        await sut.viewModel.save()

        XCTAssertTrue(sut.spy.receivedMessages.isEmpty)
    }

    func test_save_uploadsThePhotoBeforeTheDetails() async {
        let sut = makeSUT()
        sut.viewModel.pickPhoto(UIImage())
        sut.viewModel.bio = "New bio"

        await sut.viewModel.save()

        XCTAssertEqual(sut.spy.receivedMessages, [
            .uploadPhoto,
            .saveDetails(ProfileDetails(displayName: "Display Name", bio: "New bio"))
        ])
    }

    // A photo that fails must stop the save. Writing the text anyway would
    // leave half an edit behind an error saying it failed.
    func test_save_writesNothingElseAndStaysOpenWhenThePhotoFails() async {
        let sut = makeSUT()
        sut.spy.photoError = anyError
        sut.viewModel.pickPhoto(UIImage())
        sut.viewModel.bio = "New bio"

        await sut.viewModel.save()

        XCTAssertEqual(sut.spy.receivedMessages, [.uploadPhoto])
        XCTAssertNotNil(sut.viewModel.errorMessage)
        XCTAssertEqual(sut.events, [])
    }

    // The photo already reached the server, so the profile behind must reload,
    // but the screen stays open on the part that did not save.
    func test_save_reportsTheSavedPhotoWhenTheDetailsFail() async {
        let sut = makeSUT()
        sut.spy.detailsError = anyError
        sut.viewModel.pickPhoto(UIImage())
        sut.viewModel.bio = "New bio"

        await sut.viewModel.save()

        XCTAssertNotNil(sut.viewModel.errorMessage)
        XCTAssertEqual(sut.events, [.saved])
    }

    func test_save_retriesOnlyTheDetailsOnceThePhotoIsSaved() async {
        let sut = makeSUT()
        sut.spy.detailsError = anyError
        sut.viewModel.pickPhoto(UIImage())
        sut.viewModel.bio = "New bio"
        await sut.viewModel.save()
        sut.spy.detailsError = nil

        await sut.viewModel.save()

        let details = ProfileDetails(displayName: "Display Name", bio: "New bio")
        XCTAssertEqual(sut.spy.receivedMessages, [.uploadPhoto, .saveDetails(details), .saveDetails(details)])
        XCTAssertNil(sut.viewModel.errorMessage)
        XCTAssertEqual(sut.events, [.saved, .saved, .finished])
    }

    func test_canSave_isFalseForAWhitespaceOnlyName() {
        let sut = makeSUT()

        sut.viewModel.displayName = "   "

        XCTAssertFalse(sut.viewModel.canSave)
    }

    func test_save_writesNothingForAnEmptyName() async {
        let sut = makeSUT()
        sut.viewModel.displayName = ""

        await sut.viewModel.save()

        XCTAssertTrue(sut.spy.receivedMessages.isEmpty)
        XCTAssertEqual(sut.events, [])
    }

    // The limits are signup's, enforced as signup does: the extra character is
    // refused rather than accepted and rejected at Done.
    func test_displayNameAndBio_refuseCharactersPastTheirLimits() {
        let sut = makeSUT()
        let fullName = String(repeating: "a", count: ProfileDetails.displayNameLimit)
        let fullBio = String(repeating: "b", count: ProfileDetails.bioLimit)

        sut.viewModel.displayName = fullName
        sut.viewModel.displayName += "a"
        sut.viewModel.bio = fullBio
        sut.viewModel.bio += "b"

        XCTAssertEqual(sut.viewModel.displayName, fullName)
        XCTAssertEqual(sut.viewModel.bio, fullBio)
    }

    func test_cancel_closesWithoutWriting() {
        let sut = makeSUT()
        sut.viewModel.bio = "Unsaved"
        sut.viewModel.pickPhoto(UIImage())

        sut.viewModel.cancel()

        XCTAssertTrue(sut.spy.receivedMessages.isEmpty)
        XCTAssertEqual(sut.events, [.finished])
    }

    // MARK: - Helpers

    private enum Event: Equatable {
        case saved
        case finished
    }

    private final class EventLog {
        var events: [Event] = []
    }

    private struct SUT {
        let viewModel: EditProfileViewModel
        let spy: ProfileEditSpy
        let log: EventLog
        var events: [Event] { log.events }
    }

    private func makeSUT() -> SUT {
        let spy = ProfileEditSpy()
        let log = EventLog()
        let viewModel = EditProfileViewModel(
            header: ProfileHeader(
                userId: "u1",
                displayName: "Display Name",
                username: "username",
                bio: "Old bio",
                isVerified: false,
                isElite: false
            ),
            photo: nil,
            detailsWriter: spy,
            photoUploader: spy
        )
        viewModel.onSaved = { log.events.append(.saved) }
        viewModel.onFinished = { log.events.append(.finished) }
        return SUT(viewModel: viewModel, spy: spy, log: log)
    }
}

private let anyError = NSError(domain: "test", code: 0)
