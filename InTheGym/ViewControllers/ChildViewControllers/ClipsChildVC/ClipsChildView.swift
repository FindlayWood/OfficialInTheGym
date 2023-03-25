//
//  MyClipsChildView.swift
//  InTheGym
//
//  Created by Findlay Wood on 21/03/2022.
//  Copyright © 2022 FindlayWood. All rights reserved.
//

import UIKit

class ClipsChildView: UIView {
    // MARK: - Properties
    
    // MARK: - Subviews
    var searchField: UISearchBar = {
        let view = UISearchBar()
        view.placeholder = "search exercises..."
        view.showsCancelButton = true
        view.searchBarStyle = .prominent
        view.translatesAutoresizingMaskIntoConstraints = false
        return view
    }()
    lazy var collectionView: UICollectionView = {
        let view = UICollectionView(frame: .zero, collectionViewLayout: generateCollectionLayout())
        view.register(ExerciseClipsCollectionCell.self, forCellWithReuseIdentifier: ExerciseClipsCollectionCell.reuseID)
        view.backgroundColor = .white
        view.translatesAutoresizingMaskIntoConstraints = false
        return view
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
private extension ClipsChildView {
    func setupUI() {
        addSubview(collectionView)
        addSubview(searchField)
        addSubview(emptyView)
        backgroundColor = .systemBackground
        configureUI()
    }
    
    func configureUI() {
        NSLayoutConstraint.activate([
            searchField.topAnchor.constraint(equalTo: safeAreaLayoutGuide.topAnchor),
            searchField.leadingAnchor.constraint(equalTo: leadingAnchor),
            searchField.trailingAnchor.constraint(equalTo: trailingAnchor),
            collectionView.topAnchor.constraint(equalTo: searchField.bottomAnchor),
            collectionView.leadingAnchor.constraint(equalTo: leadingAnchor),
            collectionView.trailingAnchor.constraint(equalTo: trailingAnchor),
            collectionView.bottomAnchor.constraint(equalTo: bottomAnchor),
            
            emptyView.centerXAnchor.constraint(equalTo: centerXAnchor),
            emptyView.centerYAnchor.constraint(equalTo: centerYAnchor),
            emptyView.leadingAnchor.constraint(equalTo: leadingAnchor, constant: 16),
            emptyView.trailingAnchor.constraint(equalTo: trailingAnchor, constant: -16)
        ])
    }
    func generateCollectionLayout() -> UICollectionViewFlowLayout {
        let layout: UICollectionViewFlowLayout = UICollectionViewFlowLayout()
        layout.minimumLineSpacing = 16
        layout.itemSize = CGSize(width: Constants.screenSize.width / 2 - 16, height: Constants.screenSize.width / 2)
        layout.sectionInset = UIEdgeInsets(top: 8, left: 8, bottom: 8, right: 8)
        layout.scrollDirection = .vertical
        return layout
    }
}
// MARK: - Public Config
extension ClipsChildView {
    func updateDisplay(_ empty: Bool) {
        UIView.animate(withDuration: 0.3) {
            self.emptyView.isHidden = !empty
        }
    }
}
