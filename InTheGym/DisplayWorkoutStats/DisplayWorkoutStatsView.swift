//
//  DisplayWorkoutStatsView.swift
//  InTheGym
//
//  Created by Findlay Wood on 24/06/2021.
//  Copyright © 2021 FindlayWood. All rights reserved.
//

import Foundation
import UIKit

class DisplayWorkoutStatsView: UIView {
    // MARK: - Subviews
    lazy var activityIndicator: UIActivityIndicatorView = {
        let indicator = UIActivityIndicatorView(frame: self.frame)
        indicator.color = .darkColour
        return indicator
    }()
    lazy var collection: UICollectionView = {
        let collection = UICollectionView(frame: .zero, collectionViewLayout: generateLayout())
        collection.backgroundColor = .secondarySystemBackground
        collection.isScrollEnabled = true
        collection.translatesAutoresizingMaskIntoConstraints = false
        return collection
    }()
    // MARK: - Initializer
    override init(frame: CGRect) {
        super.init(frame: frame)
        setupUI()
    }
    required init?(coder: NSCoder) {
        fatalError()
    }
}
// MARK: - Setup UI
private extension DisplayWorkoutStatsView {
    func setupUI() {
        backgroundColor = .white
        addSubview(collection)
        addSubview(activityIndicator)
        constrainUI()
    }
    func constrainUI() {
        NSLayoutConstraint.activate([
            collection.topAnchor.constraint(equalTo: topAnchor),
            collection.leadingAnchor.constraint(equalTo: leadingAnchor),
            collection.trailingAnchor.constraint(equalTo: trailingAnchor),
            collection.bottomAnchor.constraint(equalTo: bottomAnchor)
        ])
    }
    func generateLayout() -> UICollectionViewFlowLayout {
        let layout: UICollectionViewFlowLayout = UICollectionViewFlowLayout()
        layout.minimumLineSpacing = 8
        layout.itemSize = CGSize(width: Constants.screenSize.width - 16, height: Constants.screenSize.height / 10)
        layout.sectionInset = UIEdgeInsets(top: 8, left: 8, bottom: 8, right: 8)
        layout.scrollDirection = .horizontal
        return layout
    }
}
