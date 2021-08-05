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
    
    lazy var activityIndicator: UIActivityIndicatorView = {
        let indicator = UIActivityIndicatorView(frame: self.frame)
        indicator.color = Constants.darkColour
        return indicator
    }()
    
    lazy var collection: UICollectionView = {
        let collection = UICollectionView(frame: .zero, collectionViewLayout: generateLayout())
        collection.backgroundColor = .white
        collection.isScrollEnabled = true
        collection.translatesAutoresizingMaskIntoConstraints = false
        return collection
    }()
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        setUpView()
    }
    required init?(coder: NSCoder) {
        fatalError()
    }
    
    private func setUpView() {
        backgroundColor = .white
        addSubview(collection)
        addSubview(activityIndicator)
        ConstrainView()
    }
    
    private func ConstrainView() {
        NSLayoutConstraint.activate([collection.topAnchor.constraint(equalTo: topAnchor),
                                     collection.leadingAnchor.constraint(equalTo: leadingAnchor),
                                     collection.trailingAnchor.constraint(equalTo: trailingAnchor),
                                     collection.bottomAnchor.constraint(equalTo: bottomAnchor)])
    }
    
    private func generateLayout() -> UICollectionViewFlowLayout {
        let layout: UICollectionViewFlowLayout = UICollectionViewFlowLayout()
        layout.minimumInteritemSpacing = 5
        layout.minimumLineSpacing = 5
        layout.itemSize = CGSize(width: Constants.screenSize.width - 10, height: Constants.screenSize.height / 10)
        layout.sectionInset = UIEdgeInsets(top: 5, left: 5, bottom: 5, right: 5)
        layout.scrollDirection = .horizontal
        return layout
    }
}
