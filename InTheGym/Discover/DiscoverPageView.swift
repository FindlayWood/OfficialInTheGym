//
//  DiscoverPageView.swift
//  InTheGym
//
//  Created by Findlay Wood on 14/03/2022.
//  Copyright © 2022 FindlayWood. All rights reserved.
//

import UIKit

class DiscoverPageView: UIView {
    
    // MARK: - Properties
    
    // MARK: - Subviews
    var titleLabel: UILabel = {
        let label = UILabel()
        label.font = UIFont(name: "Menlo-Bold", size: 25)
        label.textColor = .darkColour
        label.text = "DISCOVER"
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()
    
    var searchButton: UIButton = {
        let button = UIButton()
        let configuration = UIImage.SymbolConfiguration(pointSize: 22, weight: .semibold)
        button.setImage(UIImage(systemName: "magnifyingglass", withConfiguration: configuration), for: .normal)
        button.tintColor = .darkColour
        button.translatesAutoresizingMaskIntoConstraints = false
        return button
    }()
    lazy var collectionView: UICollectionView = {
        let view = UICollectionView(frame: .zero, collectionViewLayout: generateLayout())
        view.register(SavedWorkoutCollectionCell.self, forCellWithReuseIdentifier: SavedWorkoutCollectionCell.reuseID)
        view.register(ProgramCollectionCell.self, forCellWithReuseIdentifier: ProgramCollectionCell.reuseID)
        view.register(ExerciseClipsCollectionCell.self, forCellWithReuseIdentifier: ExerciseClipsCollectionCell.reuseID)
        view.register(ExerciseSelectionCell.self, forCellWithReuseIdentifier: ExerciseSelectionCell.reuseIdentifier)
        view.register(DiscoverSectionHeader.self, forSupplementaryViewOfKind: UICollectionView.elementKindSectionHeader, withReuseIdentifier: DiscoverSectionHeader.reuseIdentifier)
        view.backgroundColor = .white
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
private extension DiscoverPageView {
    func setupUI() {
        backgroundColor = .white
        addSubview(titleLabel)
        addSubview(searchButton)
        addSubview(collectionView)
        configureUI()
    }
    
    func configureUI() {
        NSLayoutConstraint.activate([
            titleLabel.leadingAnchor.constraint(equalTo: leadingAnchor, constant: 8),
            titleLabel.topAnchor.constraint(equalTo: safeAreaLayoutGuide.topAnchor),
            
            searchButton.centerYAnchor.constraint(equalTo: titleLabel.centerYAnchor),
            searchButton.trailingAnchor.constraint(equalTo: trailingAnchor, constant: -8),
            
            collectionView.leadingAnchor.constraint(equalTo: leadingAnchor),
            collectionView.topAnchor.constraint(equalTo: titleLabel.bottomAnchor),
            collectionView.trailingAnchor.constraint(equalTo: trailingAnchor),
            collectionView.bottomAnchor.constraint(equalTo: safeAreaLayoutGuide.bottomAnchor)
        ])
    }
    func generateLayout() -> UICollectionViewLayout {
        let layout = UICollectionViewCompositionalLayout { (sectionIndex: Int, layoutEnvironment: NSCollectionLayoutEnvironment) -> NSCollectionLayoutSection? in
            
            let sectionLayoutKind = DiscoverPageSections.allCases[sectionIndex]
            switch sectionLayoutKind {
            case .Workouts:
                return self.generateWorkoutsLayout()
            case .Exercises:
                return self.generateExercisesLayout()
            case .Programs:
                return self.generateClipsLayout()
            case .Clips:
                return self.generateClipsLayout()
            }
        }
        return layout
    }
    
    func generateWorkoutsLayout() -> NSCollectionLayoutSection {
        let itemSize = NSCollectionLayoutSize(widthDimension: .fractionalWidth(1), heightDimension: .absolute(190))
        let item = NSCollectionLayoutItem(layoutSize: itemSize)
//        item.edgeSpacing = .init(leading: .fixed(0), top: .fixed(0), trailing: .fixed(8), bottom: .fixed(0))
        item.contentInsets = NSDirectionalEdgeInsets(top: 8, leading: 8, bottom: 8, trailing: 8)
        
        let groupSize = NSCollectionLayoutSize(widthDimension: .fractionalWidth(0.9), heightDimension: .absolute(190))
        let group = NSCollectionLayoutGroup.vertical(layoutSize: groupSize, subitem: item, count: 1)
        
        
        let section = NSCollectionLayoutSection(group: group)
        section.orthogonalScrollingBehavior = .continuous
        section.boundarySupplementaryItems = [
            .init(layoutSize: .init(widthDimension: .fractionalWidth(1), heightDimension: .absolute(50)), elementKind: UICollectionView.elementKindSectionHeader, alignment: .topLeading)
        ]
        
        return section
    }
    
    func generateExercisesLayout() -> NSCollectionLayoutSection {
        let itemSize = NSCollectionLayoutSize(widthDimension: .fractionalWidth(1), heightDimension: .fractionalHeight(1/3))
        let item = NSCollectionLayoutItem(layoutSize: itemSize)
//        item.edgeSpacing = .init(leading: .fixed(8), top: nil, trailing: .fixed(8), bottom: .fixed(8))
        item.contentInsets = NSDirectionalEdgeInsets(top: 4, leading: 8, bottom: 4, trailing: 8)

        let groupSize = NSCollectionLayoutSize(widthDimension: .fractionalWidth(0.9), heightDimension: .fractionalWidth(1/2))
        let group = NSCollectionLayoutGroup.vertical(layoutSize: groupSize, subitem: item, count: 3)
        
        let section = NSCollectionLayoutSection(group: group)
        section.orthogonalScrollingBehavior = .continuous
        section.boundarySupplementaryItems = [
            .init(layoutSize: .init(widthDimension: .fractionalWidth(1), heightDimension: .absolute(50)), elementKind: UICollectionView.elementKindSectionHeader, alignment: .topLeading)
        ]
        
        return section
    }
    
    func generateProgramsLayout() -> NSCollectionLayoutSection {
        let itemSize = NSCollectionLayoutSize(widthDimension: .fractionalWidth(0.5), heightDimension: .fractionalHeight(1))
        let item = NSCollectionLayoutItem(layoutSize: itemSize)
        item.contentInsets = NSDirectionalEdgeInsets(top: 4, leading: 8, bottom: 4, trailing: 8)
        
        let groupSize = NSCollectionLayoutSize(widthDimension: .fractionalWidth(0.9), heightDimension: .estimated(160))
        let group = NSCollectionLayoutGroup.horizontal(layoutSize: groupSize, subitem: item, count: 2)
        
        let section = NSCollectionLayoutSection(group: group)
        section.orthogonalScrollingBehavior = .continuous
        section.boundarySupplementaryItems = [
            .init(layoutSize: .init(widthDimension: .fractionalWidth(1), heightDimension: .absolute(50)), elementKind: UICollectionView.elementKindSectionHeader, alignment: .topLeading)
        ]
        
        return section
    }
    
    func generateClipsLayout() -> NSCollectionLayoutSection {
        let itemSize = NSCollectionLayoutSize(widthDimension: .fractionalWidth(0.5), heightDimension: .fractionalHeight(1))
        let item = NSCollectionLayoutItem(layoutSize: itemSize)
        item.contentInsets = NSDirectionalEdgeInsets(top: 8, leading: 8, bottom: 8, trailing: 8)
        
        let groupSize = NSCollectionLayoutSize(widthDimension: .fractionalWidth(1), heightDimension: .fractionalWidth(0.5))
        let group = NSCollectionLayoutGroup.horizontal(layoutSize: groupSize, subitem: item, count: 2)
        
        let section = NSCollectionLayoutSection(group: group)
        section.orthogonalScrollingBehavior = .continuous
        section.boundarySupplementaryItems = [
            .init(layoutSize: .init(widthDimension: .fractionalWidth(1), heightDimension: .absolute(50)), elementKind: UICollectionView.elementKindSectionHeader, alignment: .topLeading)
        ]
        
        return section
    }
}
