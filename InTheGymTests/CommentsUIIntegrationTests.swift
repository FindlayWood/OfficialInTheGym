//
//  CommentsUIIntegrationTests.swift
//  InTheGymTests
//
//  Created by Findlay Wood on 10/07/2024.
//  Copyright © 2024 FindlayWood. All rights reserved.
//

import XCTest
import UIKit
import InTheGym
import ITGWorkoutKit
import ITGWorkoutKitiOS

final class CommentsUIIntegrationTests: FeedUIIntegrationTests {
    
    override func test_feedView_hasTitle() {
         let (sut, _) = makeSUT()

         sut.simulateAppearance()

         XCTAssertEqual(sut.title, feedTitle)
     }

     override func test_loadFeedActions_requestFeedFromLoader() {
         let (sut, loader) = makeSUT()
         XCTAssertEqual(loader.loadFeedCallCount, 0, "Expected no loading requests before view is loaded")

         sut.simulateAppearance()
         XCTAssertEqual(loader.loadFeedCallCount, 1, "Expected a loading request once view is loaded")

         sut.simulateUserInitiatedFeedReload()
         XCTAssertEqual(loader.loadFeedCallCount, 2, "Expected another loading request once user initiates a reload")

         sut.simulateUserInitiatedFeedReload()
         XCTAssertEqual(loader.loadFeedCallCount, 3, "Expected yet another loading request once user initiates another reload")
     }

     override func test_loadingFeedIndicator_isVisibleWhileLoadingFeed() {
         let (sut, loader) = makeSUT()

         sut.simulateAppearance()
         XCTAssertTrue(sut.isShowingLoadingIndicator, "Expected loading indicator once view is loaded")

         loader.completeFeedLoading(at: 0)
         XCTAssertFalse(sut.isShowingLoadingIndicator, "Expected no loading indicator once loading completes successfully")

         sut.simulateUserInitiatedFeedReload()
         XCTAssertTrue(sut.isShowingLoadingIndicator, "Expected loading indicator once user initiates a reload")

         loader.completeFeedLoadingWithError(at: 1)
         XCTAssertFalse(sut.isShowingLoadingIndicator, "Expected no loading indicator once user initiated loading completes with error")
     }

     override func test_loadFeedCompletion_rendersSuccessfullyLoadedFeed() {
         let image0 = makeImage(description: "a description", location: "a location")
         let image1 = makeImage(description: nil, location: "another location")
         let image2 = makeImage(description: "another description", location: nil)
         let image3 = makeImage(description: nil, location: nil)
         let (sut, loader) = makeSUT()

         sut.simulateAppearance()
         assertThat(sut, isRendering: [])

         loader.completeFeedLoading(with: [image0], at: 0)
         assertThat(sut, isRendering: [image0])

         sut.simulateUserInitiatedFeedReload()
         loader.completeFeedLoading(with: [image0, image1, image2, image3], at: 1)
         assertThat(sut, isRendering: [image0, image1, image2, image3])
     }

     override func test_loadFeedCompletion_rendersSuccessfullyLoadedEmptyFeedAfterNonEmptyFeed() {
         let image0 = makeImage()
         let image1 = makeImage()
         let (sut, loader) = makeSUT()

         sut.simulateAppearance()
         loader.completeFeedLoading(with: [image0, image1], at: 0)
         assertThat(sut, isRendering: [image0, image1])

         sut.simulateUserInitiatedFeedReload()
         loader.completeFeedLoading(with: [], at: 1)
         assertThat(sut, isRendering: [])
     }

     override func test_loadFeedCompletion_doesNotAlterCurrentRenderingStateOnError() {
         let image0 = makeImage()
         let (sut, loader) = makeSUT()

         sut.simulateAppearance()
         loader.completeFeedLoading(with: [image0], at: 0)
         assertThat(sut, isRendering: [image0])

         sut.simulateUserInitiatedFeedReload()
         loader.completeFeedLoadingWithError(at: 1)
         assertThat(sut, isRendering: [image0])
     }

     override func test_loadFeedCompletion_dispatchesFromBackgroundToMainThread() {
         let (sut, loader) = makeSUT()
         sut.simulateAppearance()

         let exp = expectation(description: "Wait for background queue")
         DispatchQueue.global().async {
             loader.completeFeedLoading(at: 0)
             exp.fulfill()
         }
         wait(for: [exp], timeout: 1.0)
     }

     override func test_loadFeedCompletion_rendersErrorMessageOnErrorUntilNextReload() {
         let (sut, loader) = makeSUT()

         sut.simulateAppearance()
         XCTAssertEqual(sut.errorMessage, nil)

         loader.completeFeedLoadingWithError(at: 0)
         XCTAssertEqual(sut.errorMessage, loadError)

         sut.simulateUserInitiatedFeedReload()
         XCTAssertEqual(sut.errorMessage, nil)
     }

     override func test_tapOnErrorView_hidesErrorMessage() {
         let (sut, loader) = makeSUT()

         sut.simulateAppearance()
         XCTAssertEqual(sut.errorMessage, nil)

         loader.completeFeedLoadingWithError(at: 0)
         XCTAssertEqual(sut.errorMessage, loadError)

         sut.simulateErrorViewTap()
         XCTAssertEqual(sut.errorMessage, nil)
     }

    // MARK: - Helpers
    
    private func makeSUT(file: StaticString = #file, line: UInt = #line) -> (sut: ListViewController, loader: LoaderSpy) {
        let loader = LoaderSpy()
        let sut = CommentsUIComposer.commentsComposedWith(commentsLoader: loader.loadPublisher)
        trackForMemoryLeaks(loader, file: file, line: line)
        trackForMemoryLeaks(sut, file: file, line: line)
        return (sut, loader)
    }
    
    private func makeImage(description: String? = nil, location: String? = nil, url: URL = URL(string: "http://any-url.com")!) -> WorkoutItem {
        return WorkoutItem(id: UUID(), description: description, location: location, image: url)
    }
}
