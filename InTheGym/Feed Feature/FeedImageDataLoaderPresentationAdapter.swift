//
//  FeedImageDataLoaderPresentationAdapter.swift
//  ITGWorkoutKitiOS
//
//  Created by Findlay Wood on 28/04/2024.
//

import Combine
import Foundation
import ITGWorkoutKit
import ITGWorkoutKitiOS

final class FeedImageDataLoaderPresentationAdapter<View: FeedImageView, Image>: FeedImageCellControllerDelegate where View.Image == Image {
    private let model: WorkoutItem
    private let imageLoader: (URL) -> FeedImageDataLoader.Publisher
    private var cancellable: Cancellable?

    var presenter: FeedImagePresenter<View, Image>?

    init(model: WorkoutItem, imageLoader: @escaping (URL) -> FeedImageDataLoader.Publisher) {
        self.model = model
        self.imageLoader = imageLoader
    }

    func didRequestImage() {
        presenter?.didStartLoadingImageData(for: model)

        let model = self.model
        cancellable = imageLoader(model.image).sink(
            receiveCompletion: { [weak self] completion in
                switch completion {
                case .finished: break

                case let .failure(error):
                    self?.presenter?.didFinishLoadingImageData(with: error, for: model)
                }

            }, receiveValue: { [weak self] data in
                self?.presenter?.didFinishLoadingImageData(with: data, for: model)
            })
    }

    func didCancelImageRequest() {
        cancellable?.cancel()
    }
}
