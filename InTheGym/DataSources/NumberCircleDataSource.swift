//
//  NumberCircleDataSource.swift
//  InTheGym
//
//  Created by Findlay Wood on 21/02/2022.
//  Copyright © 2022 FindlayWood. All rights reserved.
//

import Foundation
import UIKit
import Combine

class NumberCircleDataSource: NSObject {
    
    // MARK: - Publisher
    var numberSelected = PassthroughSubject<Int,Never>()
    var plusSelected = PassthroughSubject<Void,Never>()
    var removeItem = PassthroughSubject<Int,Never>()
    
    // MARK: - Properties
    var collectionView: UICollectionView
    
    private lazy var dataSource = makeDataSource()
    
    var subscriptions = [IndexPath: AnyCancellable]()
    
    // MARK: - Initializer
    init(collectionView: UICollectionView) {
        self.collectionView = collectionView
        super.init()
        self.collectionView.dataSource = makeDataSource()
        self.collectionView.delegate = self
        self.initialSetup()
        self.initLongPress()
    }
    
    // MARK: - Create Data Source
    func makeDataSource() -> UICollectionViewDiffableDataSource<WeeksSection,WeeksItems> {
        return UICollectionViewDiffableDataSource(collectionView: self.collectionView) { collectionView, indexPath, itemIdentifier in
            switch itemIdentifier {
            case .number(let num):
                let cell = collectionView.dequeueReusableCell(withReuseIdentifier: NumberCircleCollectionCell.reuseID, for: indexPath) as! NumberCircleCollectionCell
                cell.configure(with: num)
                return cell
            case .plus:
                let cell = collectionView.dequeueReusableCell(withReuseIdentifier: LiveWorkoutPlusCollectionCell.reuseID, for: indexPath) as! LiveWorkoutPlusCollectionCell
                self.subscriptions[indexPath] = cell.plusTappedPublisher
                    .sink(receiveValue: { [weak self] in
                        self?.plusSelected.send(())
                    })
                return cell
            }

        }
    }
    
    // MARK: - Initial Setup
    func initialSetup() {
        var snapshot = NSDiffableDataSourceSnapshot<WeeksSection,WeeksItems>()
        snapshot.appendSections([.number])
        dataSource.apply(snapshot, animatingDifferences: false)
    }
    
    func setForCreation() {
        var currentSnapshot = dataSource.snapshot()
        currentSnapshot.appendSections([.plus])
        currentSnapshot.appendItems([WeeksItems.number(1)], toSection: .number)
        currentSnapshot.appendItems([WeeksItems.plus], toSection: .plus)
        dataSource.apply(currentSnapshot, animatingDifferences: false)
    }
    
    // MARK: - Update
    func updateTable(with limit: Int, isCreating: Bool, animated: Bool) {
        var currentSnapshot = dataSource.snapshot()
        currentSnapshot.deleteAllItems()
        currentSnapshot.appendSections([.number])
        if isCreating {
            currentSnapshot.appendSections([.plus])
            currentSnapshot.appendItems([.plus], toSection: .plus)
        }
        let items = limit.allPreviousNumbers().map { WeeksItems.number($0) }
        currentSnapshot.appendItems(items, toSection: .number)
        dataSource.apply(currentSnapshot, animatingDifferences: animated)
    }
    
    // MARK: - Add
    func addNewWeek(with weekNumber: Int) {
        var currentSnapshot = dataSource.snapshot()
        currentSnapshot.appendItems([WeeksItems.number(weekNumber)], toSection: .number)
        dataSource.apply(currentSnapshot, animatingDifferences: true)
        scrollTo(number: weekNumber)
    }
    
    // MARK: - Collection View Positioning
    func scrollTo(number: Int) {
        let lastItemIndex = IndexPath(item: number - 1, section: 0)
        self.collectionView.scrollToItem(at: lastItemIndex, at: .centeredHorizontally, animated: true)
    }
    
    // MARK: - Long Press
    func initLongPress() {
        let longPress = UILongPressGestureRecognizer(target: self, action: #selector(handleLongPress(_:)))
        collectionView.addGestureRecognizer(longPress)
    }
    
    @objc func handleLongPress(_ sender: UILongPressGestureRecognizer) {
        if sender.state == .began {
            let touchPoint = sender.location(in: collectionView)
            if let indexPath = collectionView.indexPathForItem(at: touchPoint) {
                if indexPath.item != 0 {
                    guard let model = dataSource.itemIdentifier(for: indexPath) else { return }
                    switch model {
                    case .number(_):
                        self.removeItem(model)
                        self.removeItem.send(indexPath.item)
                    case .plus:
                        break
                    }
                }
            }
        }
    }
    
    // MARK: - Remove Item
    func removeItem(_ item: WeeksItems) {
        var currentSnapshot = dataSource.snapshot()
        currentSnapshot.deleteItems([item])
        dataSource.apply(currentSnapshot, animatingDifferences: true)
    }
}
// MARK: - Delegate - Select Item
extension NumberCircleDataSource: UICollectionViewDelegate {
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        guard let model = dataSource.itemIdentifier(for: indexPath) else {return}
        switch model {
        case .number(let num):
            self.numberSelected.send(num)
        case .plus:
            self.plusSelected.send(())
        }
    }

}
