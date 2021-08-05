//
//  DisplayWorkoutView.swift
//  InTheGym
//
//  Created by Findlay Wood on 29/07/2021.
//  Copyright © 2021 FindlayWood. All rights reserved.
//

import Foundation
import UIKit

class DisplayWorkoutView: UIView {
    
    private let showClipsFrame = CGRect(x: 5, y: 0, width: Constants.screenSize.width - 10, height: 100)
    private let hideClipsFrame = CGRect(x: 5, y: 0, width: Constants.screenSize.width - 10, height: 0)
    
    private var tableviewTopAnchor: NSLayoutConstraint!
    
    var isClipShowing: Bool = false
    
    lazy var clipCollection: UICollectionView = {
        let collection = UICollectionView(frame: .zero, collectionViewLayout: generateCollectionLayout())
        collection.translatesAutoresizingMaskIntoConstraints = true
        return collection
    }()
    
    var tableview: UITableView = {
        let view = UITableView()
        view.tableFooterView = UIView()
        view.rowHeight = UITableView.automaticDimension
        view.estimatedRowHeight = 380
        view.translatesAutoresizingMaskIntoConstraints = false
        return view
    }()
    
    var completedButton: UIButton = {
        let button = UIButton()
        button.setTitle("Completed", for: .normal)
        button.backgroundColor = Constants.darkColour
        button.setTitleColor(.white, for: .normal)
        button.translatesAutoresizingMaskIntoConstraints = false
        return button
    }()
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        setUpView()
    }
    required init?(coder: NSCoder) {
        fatalError()
    }
    private func setUpView() {
        backgroundColor = Constants.lightColour
        addSubview(clipCollection)
        addSubview(tableview)
        constrainView()
    }
    private func constrainView() {
        clipCollection.frame = hideClipsFrame
        tableviewTopAnchor = tableview.topAnchor.constraint(equalTo: topAnchor, constant: 0)
        NSLayoutConstraint.activate([
                                     tableviewTopAnchor,
                                     tableview.leadingAnchor.constraint(equalTo: leadingAnchor, constant: 5),
                                     tableview.trailingAnchor.constraint(equalTo: trailingAnchor, constant: -5),
                                     tableview.bottomAnchor.constraint(equalTo: bottomAnchor)
        ])
        
    }
    func showClipCollection() {
        isClipShowing = true
        tableviewTopAnchor.constant = 100
        UIView.animate(withDuration: 0.3) { [weak self] in
            guard let self = self else {return}
            self.clipCollection.frame = self.showClipsFrame
            self.layoutIfNeeded()
        }
    }
    func hideClipCollection() {
        isClipShowing = false
        tableviewTopAnchor.constant = 0
        UIView.animate(withDuration: 0.3) { [weak self] in
            guard let self = self else {return}
            self.clipCollection.frame = self.hideClipsFrame
            self.layoutIfNeeded()
        }
    }
    private func generateCollectionLayout() -> UICollectionViewFlowLayout {
        let layout: UICollectionViewFlowLayout = UICollectionViewFlowLayout()
        layout.minimumInteritemSpacing = 5
        layout.minimumLineSpacing = 5
        layout.itemSize = CGSize(width: 80, height: 80)
        layout.sectionInset = UIEdgeInsets(top: 0, left: 5, bottom: 0, right: 5)
        layout.scrollDirection = .horizontal
        return layout
    }
}
