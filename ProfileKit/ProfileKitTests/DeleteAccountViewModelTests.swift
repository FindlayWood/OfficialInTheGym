//
//  DeleteAccountViewModelTests.swift
//  ProfileKitTests
//
//  Created by Findlay Wood on 04/10/2026.
//

import XCTest
@testable import ProfileKit

@MainActor
final class DeleteAccountViewModelTests: XCTestCase {

    func test_canDelete_needsAPassword() {
        let sut = makeSUT()
        XCTAssertFalse(sut.viewModel.canDelete)

        sut.viewModel.password = "secret"

        XCTAssertTrue(sut.viewModel.canDelete)
    }

    func test_delete_sendsThePassword() async {
        let sut = makeSUT()
        sut.viewModel.password = "secret"

        await sut.viewModel.delete()

        XCTAssertEqual(sut.deleter.receivedMessages, [.deleteAccount(password: "secret")])
        XCTAssertNil(sut.viewModel.errorMessage)
    }

    func test_delete_doesNothingWithoutAPassword() async {
        let sut = makeSUT()

        await sut.viewModel.delete()

        XCTAssertTrue(sut.deleter.receivedMessages.isEmpty)
    }

    // A wrong password deleted nothing, and the screen says so: the one
    // reassurance someone needs after a failed permanent action.
    func test_delete_wrongPasswordClearsTheFieldAndSaysNothingWasDeleted() async {
        let sut = makeSUT(error: AccountDeletionError.wrongPassword)
        sut.viewModel.password = "wrong"

        await sut.viewModel.delete()

        XCTAssertEqual(sut.viewModel.password, "")
        XCTAssertEqual(sut.viewModel.errorMessage?.contains("Nothing was deleted"), true)
    }

    // Retrying is safe, so the password stays and a retry is one tap.
    func test_delete_otherFailuresKeepThePassword() async {
        let sut = makeSUT(error: AccountDeletionError.failed)
        sut.viewModel.password = "secret"

        await sut.viewModel.delete()

        XCTAssertEqual(sut.viewModel.password, "secret")
        XCTAssertNotNil(sut.viewModel.errorMessage)
        XCTAssertFalse(sut.viewModel.isDeleting)
    }

    func test_delete_reportsTooManyAttempts() async {
        let sut = makeSUT(error: AccountDeletionError.tooManyAttempts)
        sut.viewModel.password = "secret"

        await sut.viewModel.delete()

        XCTAssertEqual(sut.viewModel.errorMessage?.contains("Too many attempts"), true)
    }

    func test_password_typingClearsTheError() async {
        let sut = makeSUT(error: AccountDeletionError.failed)
        sut.viewModel.password = "secret"
        await sut.viewModel.delete()

        sut.viewModel.password = "secret2"

        XCTAssertNil(sut.viewModel.errorMessage)
    }

    // MARK: - Helpers

    private func makeSUT(error: Error? = nil) -> (viewModel: DeleteAccountViewModel, deleter: AccountDeleterSpy) {
        let deleter = AccountDeleterSpy()
        deleter.error = error
        return (DeleteAccountViewModel(deleter: deleter), deleter)
    }
}
