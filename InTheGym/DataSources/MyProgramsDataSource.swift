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
    func makeDataSource() -> UICollectionViewDiffableDataSource<SingleSection,Int> {
        return UICollectionViewDiffableDataSource(collectionView: collectionView) { collectionView, indexPath, itemIdentifier in
            let cell = collectionView.dequeueReusableCell(withReuseIdentifier: ProgramCollectionCell.reuseID, for: indexPath) as! ProgramCollectionCell
            return cell
        }
    }
    
    // MARK: - Initial Setup
    func initialSetup() {
        var snapshot = NSDiffableDataSourceSnapshot<SingleSection,Int>()
        snapshot.appendSections([.main])
        snapshot.appendItems([1,2,3,4], toSection: .main)
        dataSource.apply(snapshot, animatingDifferences: false)
    }
    
    // MARK: - Update
    

}
// MARK: - Delegate - Select Row
extension MyProgramsDataSource: UICollectionViewDelegate {
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
//        guard let model = dataSource.itemIdentifier(for: indexPath) else {return}
        
    }
}
