//
//  MyGroupsDataSource.swift
//  InTheGym
//
//  Created by Findlay Wood on 02/03/2022.
//  Copyright © 2022 FindlayWood. All rights reserved.
//

import Foundation
import UIKit
import Combine

class MyGroupsDataSource: NSObject {
    
    // MARK: - Publisher
    var groupSelected = PassthroughSubject<GroupModel,Never>()
    
    // MARK: - Properties
    var collectionView: UICollectionView
    
    private lazy var dataSource = makeDataSource()
    
    // MARK: - Initializer
    init(collectionView: UICollectionView) {
        self.collectionView = collectionView
        super.init()
        self.collectionView.dataSource = makeDataSource()
        self.collectionView.delegate = self
        self.initialSetup()
    }
    
    // MARK: - Create Data Source
    func makeDataSource() -> UICollectionViewDiffableDataSource<SingleSection,GroupModel> {
        return UICollectionViewDiffableDataSource(collectionView: self.collectionView) { collectionView, indexPath, itemIdentifier in
            let cell = collectionView.dequeueReusableCell(withReuseIdentifier: MyGroupsCollectionViewCell.reuseID, for: indexPath) as? MyGroupsCollectionViewCell
            cell?.configure(with: itemIdentifier)
            return cell
        }
    }
    
    // MARK: - Initial Setup
    func initialSetup() {
        var snapshot = NSDiffableDataSourceSnapshot<SingleSection,GroupModel>()
        snapshot.appendSections([.main])
        dataSource.apply(snapshot, animatingDifferences: false)
    }
    
    // MARK: - Update
    func updateTable(with models: [GroupModel]) {
        var currentSnapshot = dataSource.snapshot()
        currentSnapshot.appendItems(models, toSection: .main)
        dataSource.apply(currentSnapshot, animatingDifferences: true)
    }
    
    // MARK: - Add
    func addNewGroup(_ newGroup: GroupModel) {
        var currentSnapshot = dataSource.snapshot()
        currentSnapshot.appendItems([newGroup], toSection: .main)
        dataSource.apply(currentSnapshot, animatingDifferences: true)
    }
}
// MARK: - Delegate - Select Row
extension MyGroupsDataSource: UICollectionViewDelegate {
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        guard let model = dataSource.itemIdentifier(for: indexPath) else {return}
        groupSelected.send(model)
    }

}
