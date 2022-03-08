//
//  ExerciseCollectionCell.swift
//  InTheGym
//
//  Created by Findlay Wood on 22/01/2022.
//  Copyright © 2022 FindlayWood. All rights reserved.
//

import Foundation
import UIKit
import Combine

final class ExerciseCollectionCell: BaseExerciseCollectionCell {
    
    // MARK: - Publishers
    var actionPublisher: PassthroughSubject<ExerciseAction,Never> = PassthroughSubject<ExerciseAction,Never>()
    
    // MARK: - Properties
    static let reuseID = "ExerciseCollectionCellreuseID"
    var dataSource: WorkoutCollectionDataSource!
    var userInteraction: Bool!
    //private var subscriptions = Set<AnyCancellable>()
    
    // MARK: - Button Actions
    func setupButtonActions() {
        rpeButton.addTarget(self, action: #selector(rpeTapped(_:)), for: .touchUpInside)
        noteButton.addTarget(self, action: #selector(noteTapped(_:)), for: .touchUpInside)
        clipButton.addTarget(self, action: #selector(clipTapped(_:)), for: .touchUpInside)
        exerciseNameButton.addTarget(self, action: #selector(exerciseTapped(_:)), for: .touchUpInside)
    }
    @objc func rpeTapped(_ sender: UIButton) {
        actionPublisher.send(.rpeButton)
    }
    @objc func noteTapped(_ sender: UIButton) {
        actionPublisher.send(.noteButton)
    }
    @objc func clipTapped(_ sender: UIButton) {
        actionPublisher.send(.clipButton)
    }
    @objc func exerciseTapped(_ sender: UIButton) {
        actionPublisher.send(.exerciseButton)
    }
    // MARK: - Initializer
    override init(frame: CGRect) {
        super.init(frame: frame)
        setupUI()
        setupButtonActions()
    }
    required init?(coder: NSCoder) {
        super.init(coder: coder)
        setupUI()
    }
    override func prepareForReuse() {
        super.prepareForReuse()
        rpeButton.setTitle("RPE", for: .normal)
        rpeButton.setTitleColor( .systemBlue, for: .normal)
        repsLabel.text = nil
        subscriptions.removeAll()
        actionPublisher = PassthroughSubject<ExerciseAction,Never>()
    }
}

// MARK: - Public Configuration
extension ExerciseCollectionCell {
    public func configure(with model: ExerciseModel) {
        exerciseNameButton.setTitle(model.exercise, for: .normal)
        setsLabel.text = model.sets.description + " SETS"
        repsLabel.text = model.reps.repString()
        bodyTypeLabel.text = model.type.rawValue
        if let rpe = model.rpe {
            rpeButton.setTitle(rpe.description, for: .normal)
            rpeButton.setTitleColor(Constants.rpeColors[rpe - 1], for: .normal)
        }
        dataSource = .init(collectionView: collectionView, isUserInteractionEnabled: userInteraction)
        dataSource.updateTable(with: model.getSets())
        dataSource.completeButtonTapped
            .sink { [weak self] in self?.actionPublisher.send(.completed($0)) }
            .store(in: &subscriptions)
    }
    public func setUserInteraction(to enabled: Bool) {
        self.rpeButton.isUserInteractionEnabled = enabled
        self.clipButton.isUserInteractionEnabled = enabled
    }
}

