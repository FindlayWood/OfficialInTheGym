//
//  WorkoutFeedUIIntegrationTests.swift
//  InTheGymTests
//
//  Created by Findlay Wood on 15/07/2024.
//  Copyright © 2024 FindlayWood. All rights reserved.
//

import XCTest
import Combine
import UIKit
import InTheGym
import ITGWorkoutKit
import ITGWorkoutKitiOS

final class WorkoutFeedUIIntegrationTests: XCTestCase {
    
    func test_workoutFeedView_hasTitle() {
         let (sut, _) = makeSUT()

         sut.simulateAppearance()

         XCTAssertEqual(sut.title, workoutFeedTitle)
     }

     func test_loadWorkoutsActions_requestWorkoutsFromLoader() {
         let (sut, loader) = makeSUT()
         XCTAssertEqual(loader.loadWorkoutsCallCount, 0, "Expected no loading requests before view is loaded")

         sut.simulateAppearance()
         XCTAssertEqual(loader.loadWorkoutsCallCount, 1, "Expected a loading request once view is loaded")

         sut.simulateUserInitiatedReload()
         XCTAssertEqual(loader.loadWorkoutsCallCount, 2, "Expected another loading request once user initiates a reload")

         sut.simulateUserInitiatedReload()
         XCTAssertEqual(loader.loadWorkoutsCallCount, 3, "Expected yet another loading request once user initiates another reload")
     }
    
    func test_loadWorkoutsActions_runsAutomaticallyOnlyOnFirstAppearance() {
        let (sut, loader) = makeSUT()
        XCTAssertEqual(loader.loadWorkoutsCallCount, 0, "Expected no loading requests before view appears")

        sut.simulateAppearance()
        XCTAssertEqual(loader.loadWorkoutsCallCount, 1, "Expected a loading request once view appears")

        sut.simulateAppearance()
        XCTAssertEqual(loader.loadWorkoutsCallCount, 1, "Expected no loading request the second time view appears")
    }

//     func test_loadingWorkoutsIndicator_isVisibleWhileLoadingWorkouts() {
//         let (sut, loader) = makeSUT()
//
//         sut.simulateAppearance()
//         XCTAssertTrue(sut.loadingVisible, "Expected loading indicator once view is loaded")
//
////         loader.completeWorkoutsLoading(at: 0)
////         XCTAssertFalse(sut.loadingVisible, "Expected no loading indicator once loading completes successfully")
////
////         sut.simulateUserInitiatedReload()
////         XCTAssertTrue(sut.isShowingLoadingIndicator, "Expected loading indicator once user initiates a reload")
//
//         loader.completeWorkoutsLoadingWithError(at: 1)
//         XCTAssertFalse(sut.isShowingLoadingIndicator, "Expected no loading indicator once user initiated loading completes with error")
//     }

     func test_loadWorkoutsCompletion_rendersSuccessfullyLoadedWorkouts() {
         let workout0 = makeWorkout(title: "a message", exerciseCount: 2)
         let workout1 = makeWorkout(title: "another message", exerciseCount: 3)
         let (sut, loader) = makeSUT()

         sut.simulateAppearance()
         assertThat(sut, isRendering: [WorkoutFeedItem]())

         loader.completeWorkoutsLoading(with: [workout0], at: 0)
         assertThat(sut, isRendering: [workout0])

         sut.simulateUserInitiatedReload()
         loader.completeWorkoutsLoading(with: [workout0, workout1], at: 1)
         assertThat(sut, isRendering: [workout0, workout1])
     }

     func test_loadWorkoutsCompletion_rendersSuccessfullyLoadedEmptyWorkoutsAfterNonEmptyWorkouts() {
         let workout = makeWorkout()
         let (sut, loader) = makeSUT()

         sut.simulateAppearance()
         loader.completeWorkoutsLoading(with: [workout], at: 0)
         assertThat(sut, isRendering: [workout])

//         sut.simulateUserInitiatedReload()
//         loader.completeWorkoutsLoading(with: [], at: 1)
//         assertThat(sut, isRendering: [WorkoutFeedItem]())
     }

     func test_loadWorkoutsCompletion_doesNotAlterCurrentRenderingStateOnError() {
         let workout = makeWorkout()
         let (sut, loader) = makeSUT()

         sut.simulateAppearance()
         loader.completeWorkoutsLoading(with: [workout], at: 0)
         assertThat(sut, isRendering: [workout])

         sut.simulateUserInitiatedReload()
         loader.completeWorkoutsLoadingWithError(at: 1)
         assertThat(sut, isRendering: [workout])
     }

     func test_loadWorkoutsCompletion_dispatchesFromBackgroundToMainThread() {
         let (sut, loader) = makeSUT()
         sut.simulateAppearance()

         let exp = expectation(description: "Wait for background queue")
         DispatchQueue.global().async {
             loader.completeWorkoutsLoading(at: 0)
             exp.fulfill()
         }
         wait(for: [exp], timeout: 1.0)
     }

     func test_loadWorkoutsCompletion_rendersErrorMessageOnErrorUntilNextReload() {
         let (sut, loader) = makeSUT()

         sut.simulateAppearance()
         XCTAssertFalse(sut.errorVisible)

         loader.completeWorkoutsLoadingWithError(at: 0)
         XCTAssertTrue(sut.errorVisible)

         sut.simulateUserInitiatedReload()
         XCTAssertFalse(sut.errorVisible)
     }

     func test_tapOnErrorView_hidesErrorMessage() {
         let (sut, loader) = makeSUT()

         sut.simulateAppearance()
         XCTAssertFalse(sut.errorVisible)

         loader.completeWorkoutsLoadingWithError(at: 0)
         XCTAssertTrue(sut.errorVisible)

//         sut.simulateErrorViewTap()
//         XCTAssertEqual(sut.errorMessage, nil)
     }
    
    func test_deinit_cancelsRunningRequest() {
         var cancelCallCount = 0

         var sut: LoadingListViewController?

         autoreleasepool {
              sut = WorkoutFeedUIComposer.workoutsComposedWith(workoutsLoader: {
                 PassthroughSubject<[WorkoutFeedItem], Error>()
                     .handleEvents(receiveCancel: {
                         cancelCallCount += 1
                     }).eraseToAnyPublisher()
             })

             sut?.simulateAppearance()
         }

         XCTAssertEqual(cancelCallCount, 0)

         sut = nil

         XCTAssertEqual(cancelCallCount, 1)
     }

    // MARK: - Helpers
    
    private func makeSUT(file: StaticString = #filePath, line: UInt = #line) -> (sut: LoadingListViewController, loader: LoaderSpy) {
        let loader = LoaderSpy()
        let sut = WorkoutFeedUIComposer.workoutsComposedWith(workoutsLoader: loader.loadPublisher)
        trackForMemoryLeaks(loader, file: file, line: line)
        trackForMemoryLeaks(sut, file: file, line: line)
        return (sut, loader)
    }
    
    private func makeWorkout(title: String = "any message", exerciseCount: Int = 0) -> WorkoutFeedItem {
        return WorkoutFeedItem(id: UUID(), addedToListDate: Date(), createdDate: Date(), creatorID: UUID().uuidString, exerciseCount: exerciseCount, savedWorkoutID: UUID(), title: title)
    }
    
    private func assertThat(_ sut: LoadingListViewController, isRendering workouts: [WorkoutFeedItem], file: StaticString = #filePath, line: UInt = #line) {
         XCTAssertEqual(sut.numberOfRenderedWorkouts(), workouts.count, "workout count", file: file, line: line)

         let viewModel = WorkoutFeedPresenter.map(workouts)

         viewModel.workouts.enumerated().forEach { index, workout in
             XCTAssertEqual(sut.workoutTitle(at: index), workout.title, "title at \(index)", file: file, line: line)
             XCTAssertEqual(sut.workoutExerciseCount(at: index), workout.exerciseCount, "exercise count at \(index)", file: file, line: line)
         }
     }
    
    private class LoaderSpy {
        private var requests = [PassthroughSubject<[WorkoutFeedItem], Error>]()

        var loadWorkoutsCallCount: Int {
            return requests.count
        }

        func loadPublisher() -> AnyPublisher<[WorkoutFeedItem], Error> {
            let publisher = PassthroughSubject<[WorkoutFeedItem], Error>()
            requests.append(publisher)
            return publisher.eraseToAnyPublisher()
        }

        func completeWorkoutsLoading(with workouts: [WorkoutFeedItem] = [], at index: Int = 0) {
            requests[index].send(workouts)
        }

        func completeWorkoutsLoadingWithError(at index: Int = 0) {
            let error = NSError(domain: "an error", code: 0)
            requests[index].send(completion: .failure(error))
        }
    }
}
