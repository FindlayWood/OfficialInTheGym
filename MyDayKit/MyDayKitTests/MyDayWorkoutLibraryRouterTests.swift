//
//  MyDayWorkoutLibraryRouterTests.swift
//  MyDayKitTests
//
//  Created by Findlay Wood on 11/11/2026.
//

import UIKit
import XCTest
@testable import MyDayKit

@MainActor
final class MyDayWorkoutLibraryRouterTests: XCTestCase {

    // MARK: - Library state

    func test_template_deliversTheWorkoutWithThatId() {
        let sut = WorkoutLibraryState.loaded([.fixture(id: "a"), .fixture(id: "b")])

        XCTAssertEqual(sut.template(id: "b")?.id, "b")
    }

    func test_template_deliversNothingBeforeTheLibraryHasLoaded() {
        XCTAssertNil(WorkoutLibraryState.loading.template(id: "a"))
    }

    // MARK: - Opening

    func test_showTemplate_pushesTheWorkoutPageWhenTheLibraryHoldsIt() async {
        let (sut, navigation, library) = await makeSUT(templates: [.fixture(id: "a")])
        await load(library)

        sut.showTemplate(id: "a")

        XCTAssertEqual(navigation.viewControllers.count, 2)
    }

    // PROFILE can ask for a workout before MyDay's library has ever been opened. Opening nothing
    // then would make the first tap on the profile look broken.
    func test_showTemplate_loadsTheLibraryAndWaitsWhenItHasNotLoaded() async {
        let (sut, navigation, _) = await makeSUT(templates: [.fixture(id: "a")])

        sut.showTemplate(id: "a")

        await waitUntil { navigation.viewControllers.count == 2 }
        XCTAssertEqual(navigation.viewControllers.count, 2)
    }

    // The library publishes `.loaded` once for local templates and again for the remote merge.
    // Waiting with a plain subscription would push the same page twice.
    func test_showTemplate_pushesOncePerRequestWhileTheLibraryLoads() async {
        let (sut, navigation, library) = await makeSUT(templates: [.fixture(id: "a")])

        sut.showTemplate(id: "a")
        await waitUntil { navigation.viewControllers.count == 2 }
        library.addTemplate(.fixture(id: "b"))

        XCTAssertEqual(navigation.viewControllers.count, 2)
    }

    func test_showTemplate_pushesNothingForAWorkoutNotInTheLibrary() async {
        let (sut, navigation, library) = await makeSUT(templates: [.fixture(id: "a")])
        await load(library)

        sut.showTemplate(id: "missing")

        XCTAssertEqual(navigation.viewControllers.count, 1)
    }

    // MARK: - Helpers

    private func makeSUT(
        templates: [WorkoutTemplateModel],
        file: StaticString = #filePath,
        line: UInt = #line
    ) async -> (sut: MyDayWorkoutLibraryRouter, navigation: UINavigationController, library: WorkoutLibraryManager) {
        let navigation = UINavigationController(rootViewController: UIViewController())
        let library = WorkoutLibraryManager(
            local: WorkoutTemplateFetcherSpy(templates),
            remote: WorkoutTemplateFetcherSpy(templates)
        )
        let dayManager = MyDayManager(
            saver: PreviewSaver(),
            clipSaver: PreviewMyDaySaver(),
            deleteSaver: PreviewMyDaySaver(),
            loader: PreviewLoader(),
            deleter: PreviewMyDayDeleter(),
            wellnessSaver: PreviewMyDaySaver(),
            rpeSaver: PreviewMyDaySaver(),
            workoutSaver: PreviewMyDaySaver(),
            workoutStatsSaver: PreviewExerciseStatsSaver(),
            completedSessionSaver: PreviewCompletedWorkoutSessionSaver(),
            completedSessionDeleter: PreviewCompletedWorkoutSessionDeleter()
        )
        await waitUntil { dayManager.selectedDay != nil }
        let sut = MyDayWorkoutLibraryRouter(
            navigationController: navigation,
            libraryManager: library,
            dayManager: dayManager
        )
        trackForMemoryLeaks(sut, file: file, line: line)
        trackForMemoryLeaks(library, file: file, line: line)
        trackForMemoryLeaks(dayManager, file: file, line: line)
        return (sut, navigation, library)
    }

    private func load(_ library: WorkoutLibraryManager) async {
        library.load()
        await waitUntil {
            if case .loaded = library.state { return true }
            return false
        }
    }

    /// Yields to the main actor until `condition` holds, for work the router starts in a `Task`.
    private func waitUntil(timeout: TimeInterval = 1, _ condition: () -> Bool) async {
        let deadline = Date().addingTimeInterval(timeout)
        while !condition(), Date() < deadline {
            try? await Task.sleep(nanoseconds: 10_000_000)
        }
    }
}
