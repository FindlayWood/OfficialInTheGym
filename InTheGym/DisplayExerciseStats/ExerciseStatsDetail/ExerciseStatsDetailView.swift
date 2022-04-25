//
//  ExerciseStatsDetailView.swift
//  InTheGym
//
//  Created by Findlay Wood on 15/02/2022.
//  Copyright © 2022 FindlayWood. All rights reserved.
//

import Foundation
import UIKit

class ExerciseStatsDetailView: UIView {
    // MARK: - Properties
    
    // MARK: - Subviews
    var scrollView: UIScrollView = {
        let view = UIScrollView()
        view.backgroundColor = .secondarySystemBackground
        view.translatesAutoresizingMaskIntoConstraints = false
        return view
    }()
    var repCountLabel: UILabel = {
        let label = UILabel()
        label.font = .systemFont(ofSize: 100, weight: .bold)
        label.textColor = .label
        label.numberOfLines = 0
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()
    var repLabel: UILabel = {
        let label = UILabel()
        label.font = .systemFont(ofSize: 15, weight: .bold)
        label.textColor = .secondaryLabel
        label.text = "reps"
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()
    var maxWeightView: CompletedInfoView = {
        let view = CompletedInfoView()
        view.titleLabel.text = "Max Weight"
        view.addViewShadow(with: .darkColour)
        view.translatesAutoresizingMaskIntoConstraints = false
        return view
    }()
    var totalWeightView: CompletedInfoView = {
        let view = CompletedInfoView()
        view.titleLabel.text = "Total Weight"
        view.addViewShadow(with: .darkColour)
        view.translatesAutoresizingMaskIntoConstraints = false
        return view
    }()
    var averageWeightView: CompletedInfoView = {
        let view = CompletedInfoView()
        view.titleLabel.text = "Average Weight"
        view.addViewShadow(with: .darkColour)
        view.translatesAutoresizingMaskIntoConstraints = false
        return view
    }()
    var averageRPEView: CompletedInfoView = {
        let view = CompletedInfoView()
        view.titleLabel.text = "Average RPE"
        view.addViewShadow(with: .darkColour)
        view.translatesAutoresizingMaskIntoConstraints = false
        return view
    }()
    
    lazy var collectionView: UICollectionView = {
        let view = UICollectionView(frame: .zero, collectionViewLayout: generateCollectionLayout())
        view.register(ExerciseClipsCollectionCell.self, forCellWithReuseIdentifier: ExerciseClipsCollectionCell.reuseID)
        view.register(ExerciseStatsDetailHeaderView.self, forSupplementaryViewOfKind: ExerciseStatsDetailHeaderView.elementID, withReuseIdentifier: ExerciseStatsDetailHeaderView.reuseIdentifier)
        view.backgroundColor = .systemRed
        view.translatesAutoresizingMaskIntoConstraints = false
        return view
    }()
    
    // MARK: - Initializer
    override init(frame: CGRect) {
        super.init(frame: UIScreen.main.bounds)
        setupUI()
    }
    required init?(coder: NSCoder) {
        super.init(coder: coder)
        setupUI()
    }
    
}
// MARK: - Configure
private extension ExerciseStatsDetailView {
    func setupUI() {
        backgroundColor = .secondarySystemBackground
//        addSubview(collectionView)
//        addSubview(scrollView)
        addSubview(repCountLabel)
        addSubview(repLabel)
        addSubview(maxWeightView)
        addSubview(totalWeightView)
        addSubview(averageWeightView)
        addSubview(averageRPEView)
        addSubview(collectionView)
        configureUI()
    }
    
    func configureUI() {
        NSLayoutConstraint.activate([
            
            repCountLabel.topAnchor.constraint(equalTo: safeAreaLayoutGuide.topAnchor, constant: 16),
            repCountLabel.centerXAnchor.constraint(equalTo: centerXAnchor),

            repLabel.leadingAnchor.constraint(equalTo: repCountLabel.trailingAnchor),
            repLabel.centerYAnchor.constraint(equalTo: repCountLabel.centerYAnchor),

            maxWeightView.topAnchor.constraint(equalTo: repCountLabel.bottomAnchor, constant: 16),
            maxWeightView.leadingAnchor.constraint(equalTo: leadingAnchor, constant: 16),
            maxWeightView.widthAnchor.constraint(equalToConstant: (Constants.screenSize.width / 2) - 24),
            maxWeightView.heightAnchor.constraint(equalTo: maxWeightView.widthAnchor),

            totalWeightView.topAnchor.constraint(equalTo: maxWeightView.topAnchor),
            totalWeightView.trailingAnchor.constraint(equalTo: trailingAnchor, constant: -16),
            totalWeightView.widthAnchor.constraint(equalTo: maxWeightView.widthAnchor),
            totalWeightView.heightAnchor.constraint(equalTo: maxWeightView.heightAnchor),

            averageWeightView.topAnchor.constraint(equalTo: maxWeightView.bottomAnchor, constant: 16),
            averageWeightView.leadingAnchor.constraint(equalTo: leadingAnchor, constant: 16),
            averageWeightView.widthAnchor.constraint(equalTo: maxWeightView.widthAnchor),
            averageWeightView.heightAnchor.constraint(equalTo: maxWeightView.widthAnchor),

            averageRPEView.topAnchor.constraint(equalTo: averageWeightView.topAnchor),
            averageRPEView.trailingAnchor.constraint(equalTo: trailingAnchor, constant: -16),
            averageRPEView.widthAnchor.constraint(equalTo: maxWeightView.widthAnchor),
            averageRPEView.heightAnchor.constraint(equalTo: maxWeightView.heightAnchor),
            
        ])
    }
    func generateCollectionLayout() -> UICollectionViewFlowLayout {
        let layout: UICollectionViewFlowLayout = UICollectionViewFlowLayout()
        layout.minimumInteritemSpacing = 8
        layout.minimumLineSpacing = 16
        layout.itemSize = CGSize(width: Constants.screenSize.width / 2 - 16, height: Constants.screenSize.width / 2)
        layout.sectionInset = UIEdgeInsets(top: 8, left: 8, bottom: 8, right: 8)
        layout.scrollDirection = .vertical
        return layout
    }

}

// MARK: - Public Configuration
extension ExerciseStatsDetailView {
    public func configure(with model: ExerciseStatsModel) {
        repCountLabel.text = model.numberOfRepsCompleted.description
        maxWeightView.label.text = model.maxWeight.description + "kg"
        totalWeightView.label.text = model.totalWeight.description + "kg"
        averageWeightView.label.text = model.averageWeight().description + "kg"
        averageRPEView.label.text = model.averageRPE().description
    }
}
