//
//  PlayerDashBoardDataSource.swift
//  InTheGym
//
//  Created by Findlay Wood on 26/07/2022.
//  Copyright © 2022 FindlayWood. All rights reserved.
//

import Combine
import UIKit

class PlayerDashBoardDataSource: NSObject {
    
    // MARK: - Publosher
    var userSelected = PassthroughSubject<Users,Never>()
    
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
    
    // MARK: - Data Source
    func makeDataSource() -> UICollectionViewDiffableDataSource<SingleSection,Users> {
        return UICollectionViewDiffableDataSource(collectionView: self.collectionView) { collectionView, indexPath, itemIdentifier in
            let cell = collectionView.dequeueReusableCell(withReuseIdentifier: PlayerDashBoardCollectionCell.reuseID, for: indexPath) as! PlayerDashBoardCollectionCell
            cell.configure(with: itemIdentifier)
            return cell
        }
    }
    
    // MARK: - Initial Setup
    func initialSetup() {
        var snapshot = NSDiffableDataSourceSnapshot<SingleSection,Users>()
        snapshot.appendSections([.main])
        dataSource.apply(snapshot, animatingDifferences: false)
    }
    
    // MARK: - Update
    func updateTable(with users: [Users]) {
        var snapshot = NSDiffableDataSourceSnapshot<SingleSection,Users>()
        snapshot.appendSections([.main])
        snapshot.appendItems(users, toSection: .main)
        dataSource.apply(snapshot, animatingDifferences: false)
    }
    
    // MARK: - Add
    func addTable(_ user: Users) {
        var currentSnapshot = dataSource.snapshot()
        currentSnapshot.appendItems([user], toSection: .main)
        dataSource.apply(currentSnapshot, animatingDifferences: true)
    }
    func insertFirst(_ user: Users) {
        var currentSnapshot = dataSource.snapshot()
        if let firstItem = currentSnapshot.itemIdentifiers.first {
            if firstItem != user {
                currentSnapshot.insertItems([user], beforeItem: firstItem)
            }
        } else {
            currentSnapshot.appendItems([user], toSection: .main)
        }
        dataSource.apply(currentSnapshot, animatingDifferences: true)
    }
}
// MARK: - Delegate
extension PlayerDashBoardDataSource: UICollectionViewDelegate {
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        guard let user = dataSource.itemIdentifier(for: indexPath) else { return }
        userSelected.send(user)
    }
}
