//
//  DisplayWorkoutsView.swift
//  InTheGym
//
//  Created by Findlay Wood on 26/11/2021.
//  Copyright © 2021 FindlayWood. All rights reserved.
//

import UIKit

class DisplayingWorkoutsView: UIView {
    
    // MARK: - Properties
    
    // MARK: - Subviews
    var titleLabel: UILabel = {
        let label = UILabel()
        label.font = UIFont(name: "Menlo-Bold", size: 25)
        label.textColor = .darkColour
        label.text = "MYWORKOUTS"
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()
    
    var plusButton: UIButton = {
        let button = UIButton()
        let configuration = UIImage.SymbolConfiguration(pointSize: 22, weight: .semibold)
        button.setImage(UIImage(systemName: "plus.circle.fill", withConfiguration: configuration), for: .normal)
        button.tintColor = .darkColour
        button.translatesAutoresizingMaskIntoConstraints = false
        return button
    }()
    var programButton: UIButton = {
        let button = UIButton()
        let configuration = UIImage.SymbolConfiguration(pointSize: 22, weight: .semibold)
        button.setImage(UIImage(systemName: "text.book.closed.fill", withConfiguration: configuration), for: .normal)
        button.tintColor = .darkColour
        button.translatesAutoresizingMaskIntoConstraints = false
        return button
    }()
    var segment: CustomUnderlineSegmentControl = {
        let view = CustomUnderlineSegmentControl(frame: CGRect(x: 0, y: 0, width: Constants.screenSize.width, height: 32), buttonTitles: ["All","Completed","Live"])
        view.translatesAutoresizingMaskIntoConstraints = false
        return view
    }()
    lazy var collectionView: UICollectionView = {
        let view = UICollectionView(frame: .zero, collectionViewLayout: generateCollectionLayout())
        view.register(WorkoutCollectionViewCell.self, forCellWithReuseIdentifier: WorkoutCollectionViewCell.reuseID)
        view.register(DisplayWorkoutsCollectionHeader.self, forSupplementaryViewOfKind: UICollectionView.elementKindSectionHeader, withReuseIdentifier: DisplayWorkoutsCollectionHeader.reuseIdentifier)
        view.backgroundColor = .systemBackground
        view.alwaysBounceVertical = true
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
private extension DisplayingWorkoutsView {
    func setupUI() {
        backgroundColor = .systemBackground
        addSubview(titleLabel)
        addSubview(plusButton)
        addSubview(programButton)
        addSubview(segment)
        addSubview(collectionView)
        configureUI()
    }
    
    func configureUI() {
        NSLayoutConstraint.activate([
            titleLabel.leadingAnchor.constraint(equalTo: leadingAnchor, constant: 8),
            titleLabel.topAnchor.constraint(equalTo: safeAreaLayoutGuide.topAnchor),
            
            plusButton.centerYAnchor.constraint(equalTo: titleLabel.centerYAnchor),
            plusButton.trailingAnchor.constraint(equalTo: trailingAnchor, constant: -8),
            
            programButton.trailingAnchor.constraint(equalTo: plusButton.leadingAnchor, constant: -4),
            programButton.topAnchor.constraint(equalTo: plusButton.topAnchor),
            
            segment.topAnchor.constraint(equalTo: titleLabel.bottomAnchor),
            segment.leadingAnchor.constraint(equalTo: leadingAnchor),
            segment.trailingAnchor.constraint(equalTo: trailingAnchor),
            segment.heightAnchor.constraint(equalToConstant: 32),
            
            collectionView.leadingAnchor.constraint(equalTo: leadingAnchor),
            collectionView.topAnchor.constraint(equalTo: segment.bottomAnchor, constant: 0),
            collectionView.trailingAnchor.constraint(equalTo: trailingAnchor),
            collectionView.bottomAnchor.constraint(equalTo: safeAreaLayoutGuide.bottomAnchor)
        ])
    }
    
    func generateCollectionLayout() -> UICollectionViewFlowLayout {
        let layout: UICollectionViewFlowLayout = UICollectionViewFlowLayout()
        layout.minimumInteritemSpacing = 5
        layout.minimumLineSpacing = 16
        layout.estimatedItemSize = CGSize(width: Constants.screenSize.width - 16, height: 200)
        layout.sectionInset = UIEdgeInsets(top: 8, left: 8, bottom: 8, right: 8)
        layout.scrollDirection = .vertical
        layout.headerReferenceSize = CGSize(width: Constants.screenSize.width, height: 48)
        layout.sectionHeadersPinToVisibleBounds = false
        return layout
    }
}

