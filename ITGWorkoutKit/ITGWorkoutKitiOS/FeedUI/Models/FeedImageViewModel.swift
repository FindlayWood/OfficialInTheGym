//
//  FeedImageViewModel.swift
//  ITGWorkoutKitiOS
//
//  Created by Findlay Wood on 22/04/2024.
//

import Foundation
import UIKit
import ITGWorkoutKit

final class FeedImageViewModel {
    typealias Observer<T> = (T) -> Void

    private var task: FeedImageDataLoaderTask?
    private let model: WorkoutItem
    private let imageLoader: FeedImageDataLoader

    init(model: WorkoutItem, imageLoader: FeedImageDataLoader) {
        self.model = model
        self.imageLoader = imageLoader
    }

    var description: String? {
        return model.description
    }

    var location: String?  {
        return model.location
    }

    var hasLocation: Bool {
        return location != nil
    }

    var onImageLoad: Observer<UIImage>?
    var onImageLoadingStateChange: Observer<Bool>?
    var onShouldRetryImageLoadStateChange: Observer<Bool>?

    func loadImageData() {
        onImageLoadingStateChange?(true)
        onShouldRetryImageLoadStateChange?(false)
        task = imageLoader.loadImageData(from: model.image) { [weak self] result in
            self?.handle(result)
        }
    }

    private func handle(_ result: FeedImageDataLoader.Result) {
        if let image = (try? result.get()).flatMap(UIImage.init) {
            onImageLoad?(image)
        } else {
            onShouldRetryImageLoadStateChange?(true)
        }
        onImageLoadingStateChange?(false)
    }

    func cancelImageDataLoad() {
        task?.cancel()
        task = nil
    }
}
