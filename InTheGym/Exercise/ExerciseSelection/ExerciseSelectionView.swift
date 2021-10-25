//
//  ExerciseSelectionView.swift
//  InTheGym
//
//  Created by Findlay Wood on 02/09/2021.
//  Copyright © 2021 FindlayWood. All rights reserved.
//

import UIKit

@available(iOS 13, *)
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
    
    var emomView: UIImageLabelView = {
        let view = UIImageLabelView()
        view.topImage.image = UIImage(named: "emom_icon")
        view.bottomLabel.text = "EMOM"
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
        view.backgroundColor = .white
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
        let mainItem = NSCollectionLayoutItem(
          layoutSize: NSCollectionLayoutSize(
            widthDimension: .fractionalWidth(1),
            heightDimension: .fractionalHeight(1)))

        mainItem.contentInsets = NSDirectionalEdgeInsets(
          top: 2,
          leading: 2,
          bottom: 2,
          trailing: 2)
        
        let nestedGroup = NSCollectionLayoutGroup.vertical(
          layoutSize: NSCollectionLayoutSize(
            widthDimension: .fractionalWidth(0.5),
            heightDimension: .fractionalWidth(0.3)),
          subitems: [
            mainItem
          ]
        )

        let section = NSCollectionLayoutSection(group: nestedGroup)
        section.orthogonalScrollingBehavior = .continuous
        section.boundarySupplementaryItems = [
            .init(layoutSize: .init(widthDimension: .fractionalWidth(1), heightDimension: .absolute(70)), elementKind: ExerciseSelectionHeader.elementID, alignment: .topLeading)
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
@available(iOS 13, *)
private extension ExerciseSelectionView {
    func setupUI() {
        backgroundColor = .white
        topStack.addArrangedSubview(circuitView)
        topStack.addArrangedSubview(amrapView)
        topStack.addArrangedSubview(emomView)
        addSubview(topStack)
        addSubview(searchBar)
        addSubview(collectionView)
        constrainUI()
    }
    func constrainUI() {
        searchBarTopAnchor = searchBar.topAnchor.constraint(equalTo: topStack.bottomAnchor, constant: 5)
        NSLayoutConstraint.activate([
            topStack.topAnchor.constraint(equalTo: topAnchor, constant: 5),
            topStack.leadingAnchor.constraint(equalTo: leadingAnchor, constant: 10),
            topStack.trailingAnchor.constraint(equalTo: trailingAnchor, constant: -10),
            
            searchBarTopAnchor,
            //searchBar.topAnchor.constraint(equalTo: topStack.bottomAnchor, constant: 5),
            searchBar.leadingAnchor.constraint(equalTo: leadingAnchor),
            searchBar.trailingAnchor.constraint(equalTo: trailingAnchor),
            searchBar.heightAnchor.constraint(equalToConstant: 50),
            
            collectionView.topAnchor.constraint(equalTo: searchBar.bottomAnchor),
            collectionView.leadingAnchor.constraint(equalTo: leadingAnchor),
            collectionView.trailingAnchor.constraint(equalTo: trailingAnchor),
            collectionView.bottomAnchor.constraint(equalTo: bottomAnchor)
        ])
    }
}

// MARK: - Configurations
@available(iOS 13, *)
extension ExerciseSelectionView {
    public func hideStack() {
        circuitView.isHidden = true
        amrapView.isHidden = true
        emomView.isHidden = true
    }
    public func showStack() {
        circuitView.isHidden = false
        amrapView.isHidden = false
        emomView.isHidden = false
    }
    public func searchBegins() {
        UIView.animate(withDuration: 0.3) {
            self.hideStack()
            self.searchBarTopAnchor.isActive = false
            self.searchBarTopAnchor = self.searchBar.topAnchor.constraint(equalTo: self.topAnchor)
            self.searchBarTopAnchor.isActive = true
        }
    }
    public func searchEnded() {
        UIView.animate(withDuration: 0.3) {
            self.showStack()
            self.searchBarTopAnchor.isActive = false
            self.searchBarTopAnchor = self.searchBar.topAnchor.constraint(equalTo: self.topStack.bottomAnchor, constant: 5)
            self.searchBarTopAnchor.isActive = true
        }
    }
}
