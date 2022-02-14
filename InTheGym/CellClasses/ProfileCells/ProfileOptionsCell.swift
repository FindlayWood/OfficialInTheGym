//
//  ProfileOptionsCell.swift
//  InTheGym
//
//  Created by Findlay Wood on 11/02/2022.
//  Copyright © 2022 FindlayWood. All rights reserved.
//

import UIKit
import Combine

class ProfileOptionsCell: UITableViewCell {
    
    // MARK: - Publisher
    var optionSelected = PassthroughSubject<ProfileOptions,Never>()
    private var subscriptions = Set<AnyCancellable>()
    
    // MARK: - Properties
    var dataSource: ProfileOptionsDataSource!
    
    // MARK: - Cell Identifier
    static let cellID = "ProfileOptionsCellID"
    
    // MARK: - Subviews
    lazy var collection: UICollectionView = {
        let collection = UICollectionView(frame: .zero, collectionViewLayout: generateCollectionLayout())
        collection.register(OptionsCollectionCell.self, forCellWithReuseIdentifier: OptionsCollectionCell.reuseID)
        collection.showsHorizontalScrollIndicator = false
//        collection.backgroundColor = .red
        collection.backgroundColor = .white
        collection.translatesAutoresizingMaskIntoConstraints = false
        return collection
    }()
    

    
    // MARK: - Initializer
    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        setupUI()
    }
    required init?(coder: NSCoder) {
        super.init(coder: coder)
        setupUI()
    }
    override func prepareForReuse() {
        super.prepareForReuse()
//        subscriptions.removeAll()
    }
}

// MARK: - Setup UI
private extension ProfileOptionsCell {
    func setupUI() {
        backgroundColor = .white
        contentView.addSubview(collection)
        constrainUI()
        setupDataSource()
    }
    func constrainUI() {
        NSLayoutConstraint.activate([
            collection.topAnchor.constraint(equalTo: contentView.topAnchor, constant: 10),
            collection.leadingAnchor.constraint(equalTo: contentView.leadingAnchor),
            collection.trailingAnchor.constraint(equalTo: contentView.trailingAnchor),
            collection.bottomAnchor.constraint(equalTo: contentView.bottomAnchor),
            collection.heightAnchor.constraint(equalToConstant: 100)
        ])
    }
    func generateCollectionLayout() -> UICollectionViewFlowLayout {
        let layout: UICollectionViewFlowLayout = UICollectionViewFlowLayout()
        layout.minimumInteritemSpacing = 5
        layout.minimumLineSpacing = 5
        layout.itemSize = CGSize(width: 80, height: 80)
        layout.sectionInset = UIEdgeInsets(top: 0, left: 5, bottom: 0, right: 5)
        layout.scrollDirection = .horizontal
        return layout
    }
    func setupDataSource() {
        dataSource = .init(collectionView: collection)
        dataSource.optionSelected
            .sink { [weak self] in self?.optionSelected.send($0) }
            .store(in: &subscriptions)
        
//        dataSource.update(with: ProfileOptions.allCases)
                
    }
}


