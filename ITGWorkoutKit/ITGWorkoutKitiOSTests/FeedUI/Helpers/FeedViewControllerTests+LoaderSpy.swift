//
//  FeedViewControllerTests+LoaderSpy.swift
//  ITGWorkoutKitiOSTests
//
//  Created by Findlay Wood on 21/04/2024.
//

import Foundation
import ITGWorkoutKit
import ITGWorkoutKitiOS

extension FeedUIIntegrationTests {
    
    class LoaderSpy: WorkoutLoader, FeedImageDataLoader {
        
        // MARK: - FeedLoader
        
        private var feedRequests = [(WorkoutLoader.Result) -> Void]()
        
        var loadFeedCallCount: Int {
            return feedRequests.count
        }
        
        func load(completion: @escaping (WorkoutLoader.Result) -> Void) {
            feedRequests.append(completion)
        }
        
        func completeFeedLoading(with feed: [WorkoutItem] = [], at index: Int = 0) {
            feedRequests[index](.success(feed))
        }
        
        func completeFeedLoadingWithError(at index: Int = 0) {
            let error = NSError(domain: "an error", code: 0)
            feedRequests[index](.failure(error))
        }
        
        // MARK: - FeedImageDataLoader
        
        private struct TaskSpy: FeedImageDataLoaderTask {
            let cancelCallback: () -> Void
            func cancel() {
                cancelCallback()
            }
        }
        
        private var imageRequests = [(url: URL?, completion: (FeedImageDataLoader.Result) -> Void)]()
        
        var loadedImageURLs: [URL] {
            return imageRequests.compactMap { $0.url }
        }
        private(set) var cancelledImageURLs = [URL?]()
        
        func loadImageData(from url: URL?, completion: @escaping (FeedImageDataLoader.Result) -> Void) -> FeedImageDataLoaderTask {
            imageRequests.append((url, completion))
            return TaskSpy { [weak self] in self?.cancelledImageURLs.append(url) }
        }
        
        func completeImageLoading(with imageData: Data = Data(), at index: Int = 0) {
            imageRequests[index].completion(.success(imageData))
        }
        
        func completeImageLoadingWithError(at index: Int = 0) {
            let error = NSError(domain: "an error", code: 0)
            imageRequests[index].completion(.failure(error))
        }
    }
}
