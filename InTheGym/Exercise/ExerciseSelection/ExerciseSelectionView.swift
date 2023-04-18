//
//  ExerciseSelectionView.swift
//  InTheGym
//
//  Created by Findlay Wood on 02/09/2021.
//  Copyright © 2021 FindlayWood. All rights reserved.
//

import UIKit

class ExerciseSelectionView: UIView {
    
    //MARK: - Properties
    var searchBarTopAnchor: NSLayoutConstraint!
    
    // MARK: - Subviews
    
        // StackView Subviews
    var circuitView: UIImageLabelView = {
        let view = UIImageLabelView()
        view.topImage.image = UIImage(named: "circuit_icon")
        view.bottomLabel.text = "Circuit"
        view.bottomLabel.backgroundColor = .offWhiteColour
        view.bottomLabel.textColor = .black
        view.translatesAutoresizingMaskIntoConstraints = false
        return view
    }()
    
    var amrapView: UIImageLabelView = {
        let view = UIImageLabelView()
        view.topImage.image = UIImage(named: "amrap_icon")
        view.bottomLabel.text = "AMRAP"
        view.bottomLabel.backgroundColor = .offWhiteColour
        view.bottomLabel.textColor = .black
        view.translatesAutoresizingMaskIntoConstraints = false
        return view
    }()
    
    var topStack: UIStackView = {
        let stack = UIStackView()
        stack.axis = .horizontal
        stack.spacing = 10
        stack.distribution = .fillEqually
        stack.translatesAutoresizingMaskIntoConstraints = false
        return stack
    }()
    
    
        // Collection View
    lazy var collectionView: UICollectionView = {
        let view = UICollectionView(frame: .zero, collectionViewLayout: compositionalLayout)
        view.register(ExerciseSelectionCell.self, forCellWithReuseIdentifier: ExerciseSelectionCell.reuseIdentifier)
        view.register(ExerciseSelectionHeader.self, forSupplementaryViewOfKind: ExerciseSelectionHeader.elementID, withReuseIdentifier: ExerciseSelectionHeader.reuseIdentifier)
        view.backgroundColor = .secondarySystemBackground
        view.alpha = 0.0
        view.translatesAutoresizingMaskIntoConstraints = false
        return view
    }()
    
    var searchBar: UISearchBar = {
        let bar = UISearchBar()
        bar.showsCancelButton = true
        bar.placeholder = "Search exercises..."
        bar.translatesAutoresizingMaskIntoConstraints = false
        return bar
    }()
    
    // MARK: - Collection View Layout
    let compositionalLayout: UICollectionViewCompositionalLayout = {
        let itemSize = NSCollectionLayoutSize(widthDimension: .fractionalWidth(1), heightDimension: .fractionalHeight(1/3))
        let item = NSCollectionLayoutItem(layoutSize: itemSize)
        item.contentInsets = NSDirectionalEdgeInsets(top: 4, leading: 8, bottom: 4, trailing: 8)

        let groupSize = NSCollectionLayoutSize(widthDimension: .fractionalWidth(0.9), heightDimension: .fractionalWidth(1/2))
        let group = NSCollectionLayoutGroup.vertical(layoutSize: groupSize, subitem: item, count: 3)

        let section = NSCollectionLayoutSection(group: group)
        section.orthogonalScrollingBehavior = .continuous
        section.boundarySupplementaryItems = [
            .init(layoutSize: .init(widthDimension: .fractionalWidth(1), heightDimension: .absolute(50)), elementKind: ExerciseSelectionHeader.elementID, alignment: .topLeading)
        ]

        return UICollectionViewCompositionalLayout(section: section)
    }()
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        setupUI()
    }
    required init?(coder: NSCoder) {
        super.init(coder: coder)
        setupUI()
    }
}

// MARK: - Setup UI
private extension ExerciseSelectionView {
    func setupUI() {
        backgroundColor = .secondarySystemBackground
        topStack.addArrangedSubview(circuitView)
        topStack.addArrangedSubview(amrapView)
//        addSubview(topStack)
        addSubview(searchBar)
        addSubview(collectionView)
        constrainUI()
    }
    func constrainUI() {
//        searchBarTopAnchor = searchBar.topAnchor.constraint(equalTo: topStack.bottomAnchor, constant: 8)
        NSLayoutConstraint.activate([
//            topStack.topAnchor.constraint(equalTo: safeAreaLayoutGuide.topAnchor, constant: 8),
//            topStack.leadingAnchor.constraint(equalTo: leadingAnchor, constant: 16),
//            topStack.trailingAnchor.constraint(equalTo: trailingAnchor, constant: -16),
            
//            searchBarTopAnchor,
            searchBar.topAnchor.constraint(equalTo: safeAreaLayoutGuide.topAnchor),
            searchBar.leadingAnchor.constraint(equalTo: leadingAnchor),
            searchBar.trailingAnchor.constraint(equalTo: trailingAnchor),
            searchBar.heightAnchor.constraint(equalToConstant: 48),
            
            collectionView.topAnchor.constraint(equalTo: searchBar.bottomAnchor),
            collectionView.leadingAnchor.constraint(equalTo: leadingAnchor),
            collectionView.trailingAnchor.constraint(equalTo: trailingAnchor),
            collectionView.bottomAnchor.constraint(equalTo: bottomAnchor)
        ])
    }
}
// MARK: - Configurations
extension ExerciseSelectionView {
    public func hideStack() {
        circuitView.isHidden = true
        amrapView.isHidden = true
    }
    public func showStack() {
        circuitView.isHidden = false
        amrapView.isHidden = false
    }
    public func searchBegins() {
//        UIView.animate(withDuration: 0.3) {
//            self.hideStack()
//            self.searchBarTopAnchor.isActive = false
//            self.searchBarTopAnchor = self.searchBar.topAnchor.constraint(equalTo: self.safeAreaLayoutGuide.topAnchor)
//            self.searchBarTopAnchor.isActive = true
//        }
    }
    public func searchEnded() {
//        UIView.animate(withDuration: 0.3) {
//            self.showStack()
//            self.searchBarTopAnchor.isActive = false
//            self.searchBarTopAnchor = self.searchBar.topAnchor.constraint(equalTo: self.topStack.bottomAnchor, constant: 8)
//            self.searchBarTopAnchor.isActive = true
//        }
    }
}
