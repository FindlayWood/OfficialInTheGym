//
//  UploadingWorkoutView.swift
//  InTheGym
//
//  Created by Findlay Wood on 22/08/2021.
//  Copyright © 2021 FindlayWood. All rights reserved.
//

import UIKit

class UploadingWorkoutView: UIView {
    var workoutView: UIWorkoutView = {
        let view = UIWorkoutView()
        view.translatesAutoresizingMaskIntoConstraints = false
        return view
    }()
    var uploadinglabel: UILabel = {
        let label = UILabel()
        label.font = .systemFont(ofSize: 40, weight: .bold)
        label.textColor = .black
        label.text = "Uploading To"
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()
    var assigneeView: UIAssignableView = {
        let view = UIAssignableView()
        view.translatesAutoresizingMaskIntoConstraints = false
        return view
    }()
    var label: UILabel = {
        let label = UILabel()
        label.text = "Upload Options"
        label.font = .systemFont(ofSize: 40, weight: .bold)
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()
    var collectionView: UICollectionView = {
        let layout = UICollectionViewFlowLayout()
        layout.scrollDirection = .vertical
        layout.sectionInset = .init(top: 10, left: 5, bottom: 0, right: 5)
        let view = UICollectionView(frame: .zero, collectionViewLayout: layout)
        view.register(UploadingCollectionCell.self, forCellWithReuseIdentifier: UploadingCollectionCell.reuseIdentifier)
        view.register(SavingUploadCell.self, forCellWithReuseIdentifier: SavingUploadCell.reuseIdentifier)
        view.register(PrivacyUploadCell.self, forCellWithReuseIdentifier: PrivacyUploadCell.reuseIdentifier)
        view.backgroundColor = .white
        view.translatesAutoresizingMaskIntoConstraints = false
        return view
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
private extension UploadingWorkoutView {
    func setupUI() {
        backgroundColor = .white
        addSubview(workoutView)
        addSubview(uploadinglabel)
        addSubview(assigneeView)
        addSubview(label)
        addSubview(collectionView)
        constrainUI()
    }
    func constrainUI() {
        NSLayoutConstraint.activate([
            workoutView.topAnchor.constraint(equalTo: topAnchor, constant: 10),
            workoutView.leadingAnchor.constraint(equalTo: leadingAnchor, constant: 10),
            workoutView.trailingAnchor.constraint(equalTo: trailingAnchor, constant: -10),
            
            uploadinglabel.topAnchor.constraint(equalTo: workoutView.bottomAnchor, constant: 20),
            uploadinglabel.leadingAnchor.constraint(equalTo: leadingAnchor, constant: 5),
            
            assigneeView.topAnchor.constraint(equalTo: uploadinglabel.bottomAnchor, constant: 5),
            assigneeView.leadingAnchor.constraint(equalTo: leadingAnchor, constant: 10),
            assigneeView.trailingAnchor.constraint(equalTo: trailingAnchor, constant: -10),
            
            label.topAnchor.constraint(equalTo: assigneeView.bottomAnchor, constant: 20),
            label.leadingAnchor.constraint(equalTo: leadingAnchor, constant: 5),
            
            collectionView.topAnchor.constraint(equalTo: label.bottomAnchor, constant: 10),
            collectionView.leadingAnchor.constraint(equalTo: leadingAnchor),
            collectionView.trailingAnchor.constraint(equalTo: trailingAnchor),
            collectionView.bottomAnchor.constraint(equalTo: bottomAnchor)
        ])
    }
}

// MARK: - Configure
extension UploadingWorkoutView {
    public func configure(with uploadable: UploadableWorkout) {
        assigneeView.configure(with: uploadable.assignee)
//        workoutView.configure(with: uploadable.workout)
    }
}
