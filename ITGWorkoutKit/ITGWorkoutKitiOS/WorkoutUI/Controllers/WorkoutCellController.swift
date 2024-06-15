//
//  WorkoutCellController.swift
//  ITGWorkoutKitiOS
//
//  Created by Findlay Wood on 15/06/2024.
//

import UIKit
import ITGWorkoutKit

public protocol WorkoutCellControllerDelegate {
    func didRequestImage()
    func didCancelImageRequest()
}

public final class WorkoutCellController {
    private let delegate: WorkoutCellControllerDelegate
    private var cell: WorkoutFeedCell?

    public init(delegate: WorkoutCellControllerDelegate) {
        self.delegate = delegate
    }

    func view(in tableView: UITableView) -> UITableViewCell {
        cell = tableView.dequeueReusableCell()
        delegate.didRequestImage()
        return cell!
    }

    func preload() {
        delegate.didRequestImage()
    }

    func cancelLoad() {
        releaseCellForReuse()
        delegate.didCancelImageRequest()
    }
    
    public func display(_ viewModel: FeedWorkoutViewModel) {
        cell?.titleLabel.text = viewModel.title
        cell?.workoutContainer.isShimmering = viewModel.isLoading
        cell?.feedWorkoutRetryButton.isHidden = !viewModel.shouldRetry
        cell?.onRetry = delegate.didRequestImage
        
        cell?.onReuse = { [weak self] in
            self?.releaseCellForReuse()
        }
    }
    
    private func releaseCellForReuse() {
        cell?.onReuse = nil
        cell = nil
    }
}
