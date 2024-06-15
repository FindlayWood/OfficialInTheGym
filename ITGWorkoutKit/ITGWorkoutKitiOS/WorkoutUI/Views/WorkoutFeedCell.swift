//
//  WorkoutFeedCell.swift
//  ITGWorkoutKitiOS
//
//  Created by Findlay Wood on 13/06/2024.
//

import UIKit
import SwiftUI

public final class WorkoutFeedCell: UITableViewCell {
    @IBOutlet private(set) public var workoutContainer: UIView!
    @IBOutlet private(set) public var titleLabel: UILabel!
    @IBOutlet private(set) public var feedWorkoutRetryButton: UIButton!

    var onRetry: (() -> Void)?
    var onReuse: (() -> Void)?

    @IBAction private func retryButtonTapped() {
        onRetry?()
    }

    public override func prepareForReuse() {
        super.prepareForReuse()

        onReuse?()
    }
}
