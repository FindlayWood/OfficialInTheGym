//
//  WorkoutCreationOptionsView.swift
//  InTheGym
//
//  Created by Findlay Wood on 07/06/2022.
//  Copyright © 2022 FindlayWood. All rights reserved.
//

import UIKit

class WorkoutCreationOptionsView: UIView {
    // MARK: - Properties
    
    // MARK: - Subviews
    var doneButton: UIButton = {
        let button = UIButton()
        button.setTitle("Done", for: .normal)
        button.setTitleColor(.darkColour, for: .normal)
        button.titleLabel?.font = .systemFont(ofSize: 16, weight: .bold)
        button.translatesAutoresizingMaskIntoConstraints = false
        return button
    }()
    var privacyView: PrivacyView = {
        let view = PrivacyView()
        view.translatesAutoresizingMaskIntoConstraints = false
        return view
    }()
    var saveView: UISaveView = {
        let view = UISaveView()
        view.translatesAutoresizingMaskIntoConstraints = false
        return view
    }()
    var assignView: AssignView = {
        let view = AssignView()
        view.translatesAutoresizingMaskIntoConstraints = false
        return view
    }()
    lazy var middleStack: UIStackView = {
        let view = UIStackView(arrangedSubviews: [assignView, privacyView, saveView])
        view.axis = .horizontal
        view.distribution = .fillEqually
        view.spacing = 4
        view.translatesAutoresizingMaskIntoConstraints = false
        return view
    }()
    var tagLabel: UILabel = {
        let label = UILabel()
        label.font = .systemFont(ofSize: 20, weight: .semibold)
        label.text = "Tags"
        label.textColor = .label
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()
    var addTagButton: UIButton = {
        let button = UIButton()
        button.setImage(UIImage(systemName: "plus.circle.fill", withConfiguration: UIImage.SymbolConfiguration(pointSize: 60)), for: .normal)
        button.tintColor = .lightColour
        button.translatesAutoresizingMaskIntoConstraints = false
        return button
    }()
    lazy var collectionView: UICollectionView = {
        let view = UICollectionView(frame: .zero, collectionViewLayout: generateCollectionLayout())
        view.register(ExerciseTagCell.self, forCellWithReuseIdentifier: ExerciseTagCell.reuseID)
        view.backgroundColor = .secondarySystemBackground
        view.translatesAutoresizingMaskIntoConstraints = false
        return view
    }()
    var emptyMessage: UILabel = {
        let label = UILabel()
        label.text = "No Tags.\n Tap the + icon below to add a tag. \n Tags help users search for workouts."
        label.font = .systemFont(ofSize: 20, weight: .semibold)
        label.textColor = .secondaryLabel
        label.textAlignment = .center
        label.backgroundColor = .clear
        label.numberOfLines = 0
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
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
private extension WorkoutCreationOptionsView {
    func setupUI() {
        backgroundColor = .secondarySystemBackground
        addSubview(doneButton)
        addSubview(middleStack)
        addSubview(tagLabel)
        addSubview(collectionView)
        addSubview(addTagButton)
        addSubview(emptyMessage)
        configureUI()
    }
    func configureUI() {
        NSLayoutConstraint.activate([
            doneButton.topAnchor.constraint(equalTo: topAnchor, constant: 8),
            doneButton.trailingAnchor.constraint(equalTo: trailingAnchor, constant: -8),
            
            middleStack.topAnchor.constraint(equalTo: doneButton.bottomAnchor),
            middleStack.leadingAnchor.constraint(equalTo: leadingAnchor),
            middleStack.trailingAnchor.constraint(equalTo: trailingAnchor),
            
            tagLabel.topAnchor.constraint(equalTo: middleStack.bottomAnchor, constant: 16),
            tagLabel.leadingAnchor.constraint(equalTo: leadingAnchor, constant: 16),
            
            collectionView.topAnchor.constraint(equalTo: tagLabel.bottomAnchor, constant: 8),
            collectionView.leadingAnchor.constraint(equalTo: leadingAnchor),
            collectionView.trailingAnchor.constraint(equalTo: trailingAnchor),
            collectionView.bottomAnchor.constraint(equalTo: bottomAnchor),
            
            addTagButton.trailingAnchor.constraint(equalTo: trailingAnchor, constant: -8),
            addTagButton.bottomAnchor.constraint(equalTo: safeAreaLayoutGuide.bottomAnchor, constant: -8),
            
            emptyMessage.centerXAnchor.constraint(equalTo: collectionView.centerXAnchor),
            emptyMessage.centerYAnchor.constraint(equalTo: collectionView.centerYAnchor),
            emptyMessage.widthAnchor.constraint(equalTo: collectionView.widthAnchor, constant: -16)
        ])
    }
    func generateCollectionLayout() -> UICollectionViewFlowLayout {
        let layout: UICollectionViewFlowLayout = UICollectionViewFlowLayout()
        layout.minimumLineSpacing = 16
        layout.itemSize = CGSize(width: Constants.screenSize.width - 16, height: 60)
        layout.sectionInset = UIEdgeInsets(top: 8, left: 8, bottom: 0, right: 8)
        layout.scrollDirection = .vertical
        return layout
    }
}
// MARK: - Public Config
extension WorkoutCreationOptionsView {
    public func configure(with user: Users?) {
        if let user = user {
            assignView.configure(with: user)
        } else {
            assignView.isHidden = true
        }
    }
}
