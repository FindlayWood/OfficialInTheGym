//
//  DisplayWorkoutsViewController.swift
//  InTheGym
//
//  Created by Findlay Wood on 26/11/2021.
//  Copyright © 2021 FindlayWood. All rights reserved.
//

import UIKit
import Combine

class DisplayingWorkoutsViewController: UIViewController {
    
    weak var coordinator: WorkoutsCoordinator?
    
    var display = DisplayingWorkoutsView()
    
    var viewModel = DisplayingWorkoutsViewModel()
    
    private lazy var dataSource = setupDataSource()
    
    var subscriptions = Set<AnyCancellable>()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .lightColour
        display.collectionView.dataSource = dataSource
        updateTable()
    }
    
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        display.frame = getFullViewableFrame()
        view.addSubview(display)
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
    }
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        navigationController?.setNavigationBarHidden(true, animated: true)
    }
}

extension DisplayingWorkoutsViewController {
    func setupDataSource() -> UICollectionViewDiffableDataSource<Section, WorkoutModel> {
        return UICollectionViewDiffableDataSource(collectionView: display.collectionView) { collectionView, indexPath, itemIdentifier in
            let cell = collectionView.dequeueReusableCell(withReuseIdentifier: WorkoutCollectionViewCell.reuseID, for: indexPath) as! WorkoutCollectionViewCell
            cell.configure(with: itemIdentifier)
            return cell
        }
        
        
//        return UICollectionViewDiffableDataSource(tableView: display.tableview) { tableView, indexPath, itemIdentifier in
//            let cell = tableView.dequeueReusableCell(withIdentifier: WorkoutTableViewCell.cellID, for: indexPath) as! WorkoutTableViewCell
//            cell.configure(with: itemIdentifier)
//            return cell
//        }
    }
    
    func updateTable(animate: Bool = true) {
        
        var snapshot = NSDiffableDataSourceSnapshot<Section, WorkoutModel>()
        snapshot.appendSections([.main])
        
        viewModel.workouts
            .sink { _ in
                print("no")
            } receiveValue: { [weak self] newWorkouts in
                guard let self = self else {return}
                snapshot.appendItems(newWorkouts, toSection: .main)
                self.dataSource.apply(snapshot, animatingDifferences: animate)
            }
            .store(in: &subscriptions)
    }
}

enum Section {
    case main
}
