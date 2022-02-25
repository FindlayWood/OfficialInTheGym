//
//  MyProgramsDataSource.swift
//  InTheGym
//
//  Created by Findlay Wood on 22/02/2022.
//  Copyright © 2022 FindlayWood. All rights reserved.
//

import Foundation
import UIKit
import Combine

class MyProgramsDataSource: NSObject {
    
    // MARK: - Publisher
    var workoutSelected = PassthroughSubject<SavedWorkoutModel,Never>()
    var plusSelected = PassthroughSubject<Void,Never>()
    
    // MARK: - Properties
    var collectionView: UICollectionView
    
    private lazy var dataSource = makeDataSource()
    
    private var subscriptions = [IndexPath: AnyCancellable]()
    
    // MARK: - Initializer
    init(collectionView: UICollectionView) {
        self.collectionView = collectionView
        super.init()
        self.collectionView.dataSource = makeDataSource()
        self.collectionView.delegate = self
        self.initialSetup()
    }
    
    // MARK: - Create Data Source
    func makeDataSource() -> UICollectionViewDiffableDataSource<SingleSection,MyProgramsItems> {
        return UICollectionViewDiffableDataSource(collectionView: collectionView) { collectionView, indexPath, itemIdentifier in
            let cell = collectionView.dequeueReusableCell(withReuseIdentifier: ProgramCollectionCell.reuseID, for: indexPath) as! ProgramCollectionCell
            switch itemIdentifier {
            case .program(let model):
                cell.configure(with: model)
            case .savedProgram(let model):
                cell.configure(with: model)
            }
            return cell
        }
    }
    
    // MARK: - Initial Setup
    func initialSetup() {
        var snapshot = NSDiffableDataSourceSnapshot<SingleSection,MyProgramsItems>()
        snapshot.appendSections([.main])
        dataSource.apply(snapshot, animatingDifferences: false)
    }
    
    // MARK: - Update
    func updateTable(with models: [ProgramModel]) {
        let items = models.map { MyProgramsItems.program($0) }
        var currentSnapshot = dataSource.snapshot()
        currentSnapshot.deleteAllItems()
        currentSnapshot.appendSections([.main])
        currentSnapshot.appendItems(items, toSection: .main)
        dataSource.apply(currentSnapshot, animatingDifferences: true)
    }
    func updateTable(with models: [SavedProgramModel]) {
        let items = models.map { MyProgramsItems.savedProgram($0) }
        var currentSnapshot = dataSource.snapshot()
        currentSnapshot.deleteAllItems()
        currentSnapshot.appendSections([.main])
        currentSnapshot.appendItems(items, toSection: .main)
        dataSource.apply(currentSnapshot, animatingDifferences: true)
    }
    

}
// MARK: - Delegate - Select Row
extension MyProgramsDataSource: UICollectionViewDelegate {
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
//        guard let model = dataSource.itemIdentifier(for: indexPath) else {return}
        
    }
}
