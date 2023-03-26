//
//  ExerciseClipsView.swift
//  InTheGym
//
//  Created by Findlay Wood on 17/02/2022.
//  Copyright © 2022 FindlayWood. All rights reserved.
//

import Foundation
import UIKit

class ExerciseClipsView: UIView {
    // MARK: - Properties
    
    // MARK: - Subviews
    lazy var collectionView: UICollectionView = {
        let view = UICollectionView(frame: .zero, collectionViewLayout: generateCollectionLayout())
        view.register(ExerciseClipsCollectionCell.self, forCellWithReuseIdentifier: ExerciseClipsCollectionCell.reuseID)
        view.backgroundColor = .secondarySystemBackground
        view.translatesAutoresizingMaskIntoConstraints = false
        return view
    }()
    var plusButton: UIButton = {
        let button = UIButton()
        button.tintColor = .lightColour
        button.setImage(UIImage(systemName: "plus.circle.fill", withConfiguration: UIImage.SymbolConfiguration(pointSize: 60)), for: .normal)
        button.translatesAutoresizingMaskIntoConstraints = false
        return button
    }()
    var emptyView: EmptyClipsView = {
        let view = EmptyClipsView()
        view.isHidden = true
        view.translatesAutoresizingMaskIntoConstraints = false
        return view
    }()
    // MARK: - Initializer
    override init(frame: CGRect) {
        super.init(frame: frame)
        setupUI()
    }
    required init?(coder: NSCoder) {
        super.init(coder: coder)
        setupUI()
    }
}
// MARK: - Configure
private extension ExerciseClipsView {
    func setupUI() {
        addSubview(collectionView)
        addSubview(emptyView)
        addSubview(plusButton)
        backgroundColor = .secondarySystemBackground
        configureUI()
    }
    func configureUI() {
        addFullConstraint(to: collectionView)
        NSLayoutConstraint.activate([
            emptyView.centerXAnchor.constraint(equalTo: centerXAnchor),
            emptyView.centerYAnchor.constraint(equalTo: centerYAnchor),
            emptyView.leadingAnchor.constraint(equalTo: leadingAnchor, constant: 16),
            emptyView.trailingAnchor.constraint(equalTo: trailingAnchor, constant: -16),
            
            plusButton.trailingAnchor.constraint(equalTo: collectionView.trailingAnchor, constant: -8),
            plusButton.bottomAnchor.constraint(equalTo: collectionView.bottomAnchor, constant: -16)
        ])
    }
    func generateCollectionLayout() -> UICollectionViewFlowLayout {
        let layout: UICollectionViewFlowLayout = UICollectionViewFlowLayout()
        layout.minimumLineSpacing = 16
        layout.itemSize = CGSize(width: Constants.screenSize.width / 2 - 16, height: Constants.screenSize.width / 2)
        layout.sectionInset = UIEdgeInsets(top: 8, left: 8, bottom: 0, right: 8)
        layout.scrollDirection = .vertical
        return layout
    }
}
// MARK: - Public Config
extension ExerciseClipsView {
    func updateDisplay(_ empty: Bool) {
        UIView.animate(withDuration: 0.3) {
            self.emptyView.isHidden = !empty
        }
    }
}
