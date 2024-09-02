//
//  FeedViewControllerTests+LoaderSpy.swift
//  ITGWorkoutKitiOSTests
//
//  Created by Findlay Wood on 21/04/2024.
//

import Combine
import Foundation
import ITGWorkoutKit
import ITGWorkoutKitiOS

extension FeedUIIntegrationTests {
    
    class LoaderSpy: FeedImageDataLoader {
        
        // MARK: - FeedLoader
        
        private var feedRequests = [PassthroughSubject<[WorkoutItem], Error>]()
        
        var loadFeedCallCount: Int {
            return feedRequests.count
        }
        
        func loadPublisher() -> AnyPublisher<[WorkoutItem], Error> {
             let publisher = PassthroughSubject<[WorkoutItem], Error>()
             feedRequests.append(publisher)
             return publisher.eraseToAnyPublisher()
         }
        
        func completeFeedLoading(with feed: [WorkoutItem] = [], at index: Int = 0) {
            feedRequests[index].send(feed)
        }
        
        func completeFeedLoadingWithError(at index: Int = 0) {
            let error = NSError(domain: "an error", code: 0)
            feedRequests[index].send(completion: .failure(error))
        }
        
        // MARK: - FeedImageDataLoader
        
        private struct TaskSpy: FeedImageDataLoaderTask {
            let cancelCallback: () -> Void
            func cancel() {
                cancelCallback()
            }
        }
        
        private var imageRequests = [(url: URL, completion: (FeedImageDataLoader.Result) -> Void)]()
        
        var loadedImageURLs: [URL] {
            return imageRequests.compactMap { $0.url }
        }
        private(set) var cancelledImageURLs = [URL?]()
        
        func loadImageData(from url: URL, completion: @escaping (FeedImageDataLoader.Result) -> Void) -> FeedImageDataLoaderTask {
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
