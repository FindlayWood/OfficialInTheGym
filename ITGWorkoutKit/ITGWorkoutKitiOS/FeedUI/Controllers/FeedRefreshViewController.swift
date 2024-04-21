//
//  FeedRefreshViewController.swift
//  ITGWorkoutKitiOS
//
//  Created by Findlay Wood on 21/04/2024.
//

import UIKit
import ITGWorkoutKit

public final class FeedRefreshViewController: NSObject {
    public lazy var view: UIRefreshControl = {
        let view = UIRefreshControl()
        view.addTarget(self, action: #selector(refresh), for: .valueChanged)
        return view
    }()

    private let feedLoader: WorkoutLoader

    init(feedLoader: WorkoutLoader) {
        self.feedLoader = feedLoader
    }

    var onRefresh: (([WorkoutItem]) -> Void)?

    @objc func refresh() {
        view.beginRefreshing()
        feedLoader.load { [weak self] result in
            if let feed = try? result.get() {
                self?.onRefresh?(feed)
            }
            self?.view.endRefreshing()
        }
    }
}
