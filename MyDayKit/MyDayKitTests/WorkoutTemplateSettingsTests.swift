//
//  WorkoutTemplateSettingsTests.swift
//  MyDayKitTests
//
//  Created by Findlay Wood on 13/11/2026.
//

import XCTest
@testable import MyDayKit

@MainActor
final class WorkoutTemplateSettingsTests: XCTestCase {

    // MARK: - Who may edit

    func test_isEditable_deliversTrueForAWorkoutTheUserBuilt() {
        XCTAssertTrue(template(createdBy: "me").isEditable(by: "me"))
    }

    func test_isEditable_deliversFalseForSomeoneElsesWorkout() {
        XCTAssertFalse(template(createdBy: "them").isEditable(by: "me"))
    }

    // A copy saved from DISCOVER is filed under the saver. Judged by `createdBy` alone it would be
    // theirs to publish, listing someone else's workout on DISCOVER under their name.
    func test_isEditable_deliversFalseForACopySavedFromDiscover() {
        let sut = template(createdBy: "them").copy(savedBy: "me")

        XCTAssertFalse(sut.isEditable(by: "me"))
    }

    // MARK: - The page

    func test_page_offersSettingsOnTheUsersOwnWorkout() {
        XCTAssertNotNil(page(for: template(createdBy: "me")).editor)
    }

    // The page decides this once for both ways it opens, MyDay's library and another tab.
    func test_page_offersNoSettingsOnACopyOrWithoutASaver() {
        XCTAssertNil(page(for: template(createdBy: "them").copy(savedBy: "me")).editor)
        XCTAssertNil(page(for: template(createdBy: "me"), settings: nil).editor)
    }

    // MARK: - The edited workout

    // The id is what the library, the sync queue and Firestore replace by, and `createdAt` the
    // library's sort key. Changing either would add a second workout, or move this one in the list.
    func test_withSettings_keepsTheIdAndCreationDate() {
        let source = template()

        let sut = source.withSettings(isPublic: true, tags: ["legs"], updatedAt: laterDate)

        XCTAssertEqual(sut.id, source.id)
        XCTAssertEqual(sut.createdAt, source.createdAt)
        XCTAssertEqual(sut.updatedAt, laterDate)
        XCTAssertTrue(sut.isPublic)
        XCTAssertEqual(sut.tags, ["legs"])
    }

    func test_withSettings_storesNoTagsAsNil() {
        let sut = template(tags: ["legs"]).withSettings(isPublic: false, tags: [], updatedAt: laterDate)

        XCTAssertNil(sut.tags)
    }

    // MARK: - Tags

    func test_appending_normalisesTheTag() {
        XCTAssertEqual(WorkoutTag.appending("Leg Day!", to: []), ["legday"])
    }

    func test_appending_ignoresATagAlreadyThereOrEmpty() {
        XCTAssertEqual(WorkoutTag.appending("LEGS", to: ["legs"]), ["legs"])
        XCTAssertEqual(WorkoutTag.appending("!!", to: ["legs"]), ["legs"])
    }

    // MARK: - Saving

    func test_save_writesTheWorkoutWithItsNewSettings() async {
        let (sut, saver, _) = makeSUT()

        sut.isPublic = true
        sut.addTag("Legs")
        await sut.save()

        XCTAssertEqual(saver.receivedMessages, [.upload(id: "w1", isPublic: true, tags: ["legs"], updatedAt: laterDate)])
        XCTAssertTrue(sut.template.isPublic)
    }

    // The sheet saves whenever it closes. Opening and closing it must not rewrite the workout,
    // which would re-run the server's card and tag triggers for nothing.
    func test_save_writesNothingWhenNothingChanged() async {
        let (sut, saver, _) = makeSUT()

        await sut.save()

        XCTAssertTrue(saver.receivedMessages.isEmpty)
    }

    // Changing a setting and changing it back is no change.
    func test_save_writesNothingWhenASettingIsPutBack() async {
        let (sut, saver, _) = makeSUT()

        sut.isPublic = true
        sut.isPublic = false
        await sut.save()

        XCTAssertTrue(saver.receivedMessages.isEmpty)
    }

    // MyDay's library and PROFILE's All workouts both read this manager. Without the update they
    // would show the old visibility until the next remote fetch.
    func test_save_putsTheEditedWorkoutInTheLibrary() async {
        let (sut, _, library) = makeSUT()
        await load(library)

        sut.isPublic = true
        await sut.save()

        XCTAssertEqual(library.state.template(id: "w1")?.isPublic, true)
    }

    // The device's JSON stores dates to the whole second. A finer stamp would read back older than
    // the copy in memory, and the merge could pick the stale one.
    func test_save_stampsUpdatedAtInWholeSeconds() async {
        let (sut, saver, _) = makeSUT(now: laterDate.addingTimeInterval(0.75))

        sut.isPublic = true
        await sut.save()

        XCTAssertEqual(saver.receivedMessages.first, .upload(id: "w1", isPublic: true, tags: nil, updatedAt: laterDate))
    }

    // A failed save must not leave the sheet showing a visibility the workout does not have.
    func test_save_putsTheDraftBackAndReportsOnFailure() async {
        let (sut, saver, library) = makeSUT()
        await load(library)
        saver.error = anyNSError()

        sut.isPublic = true
        sut.addTag("legs")
        await sut.save()

        XCTAssertFalse(sut.isPublic)
        XCTAssertEqual(sut.tags, [])
        XCTAssertNotNil(sut.saveError)
        XCTAssertEqual(library.state.template(id: "w1")?.isPublic, false)
    }

    func test_save_clearsTheErrorOnTheNextSuccess() async {
        let (sut, saver, _) = makeSUT()
        saver.error = anyNSError()
        sut.isPublic = true
        await sut.save()

        saver.error = nil
        sut.isPublic = true
        await sut.save()

        XCTAssertNil(sut.saveError)
    }

    // MARK: - Helpers

    private func makeSUT(
        now: Date? = nil,
        file: StaticString = #filePath,
        line: UInt = #line
    ) -> (sut: WorkoutTemplateSettingsEditor, saver: WorkoutTemplateUploaderSpy, library: WorkoutLibraryManager) {
        let source = template()
        let saver = WorkoutTemplateUploaderSpy()
        let library = WorkoutLibraryManager(
            local: WorkoutTemplateFetcherSpy([source]),
            remote: WorkoutTemplateFetcherSpy([source])
        )
        let stamp = now ?? laterDate
        let sut = WorkoutTemplateSettingsEditor(
            template: source,
            saver: saver,
            libraryManager: library,
            now: { stamp }
        )
        trackForMemoryLeaks(sut, file: file, line: line)
        trackForMemoryLeaks(saver, file: file, line: line)
        trackForMemoryLeaks(library, file: file, line: line)
        return (sut, saver, library)
    }

    private func page(
        for template: WorkoutTemplateModel,
        settings: WorkoutTemplateSettingsDependencies? = WorkoutTemplateSettingsDependencies(saver: WorkoutTemplateUploaderSpy(), userId: "me")
    ) -> MyDayWorkoutTemplatePage {
        MyDayWorkoutTemplatePage(
            template: template,
            settings: settings,
            libraryManager: WorkoutLibraryManager(local: WorkoutTemplateFetcherSpy(), remote: WorkoutTemplateFetcherSpy()),
            scheduleManager: nil,
            onAddToTodayTapped: nil,
            onReadyToDismiss: nil,
            onBack: nil
        )
    }

    private func template(createdBy: String = "me", tags: [String]? = nil) -> WorkoutTemplateModel {
        WorkoutTemplateModel(
            id: "w1",
            title: "Leg day",
            description: nil,
            exercises: [],
            createdBy: createdBy,
            isPublic: false,
            tags: tags,
            estimatedDuration: nil,
            difficulty: nil,
            createdAt: fixedDate,
            updatedAt: fixedDate
        )
    }

    private func load(_ library: WorkoutLibraryManager) async {
        library.load()
        let deadline = Date().addingTimeInterval(1)
        while Date() < deadline {
            if case .loaded = library.state { return }
            try? await Task.sleep(nanoseconds: 10_000_000)
        }
    }

    private let fixedDate = Date(timeIntervalSince1970: 1_800_000_000)
    private let laterDate = Date(timeIntervalSince1970: 1_800_086_400)
}
