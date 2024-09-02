//
//  FeedViewController.swift
//  ITGWorkoutKitiOS
//
//  Created by Findlay Wood on 19/04/2024.
//

import UIKit
import ITGWorkoutKit

public final class ListViewController: UITableViewController, UITableViewDataSourcePrefetching, ResourceLoadingView, ResourceErrorView {
    public var onRefresh: (() -> Void)?
    public var cells: [UITableViewCell.Type] = [UITableViewCell.Type]()
    
    private(set) public var errorView = ErrorView()
    public var refreshController = RefreshViewController()
    
    private lazy var dataSource: UITableViewDiffableDataSource<Int, CellController> = {
         .init(tableView: tableView) { (tableView, index, controller) in
             controller.dataSource.tableView(tableView, cellForRowAt: index)
         }
     }()
    
    private var onViewIsAppearing: ((ListViewController) -> ())?

    public override func viewDidLoad() {
        super.viewDidLoad()
        
        configureTableView()
        configureTraitCollectionObservers()
        
        refreshControl = refreshController.view
        
        refreshController.onRefresh = { [weak self] in
            self?.onRefresh?()
        }
        
        onViewIsAppearing = { vc in
            vc.onViewIsAppearing = nil
//            vc.refresh()
            vc.refreshController.refresh()
            
        }
    }
    
    private func configureTraitCollectionObservers() {
        registerForTraitChanges(
            [UITraitPreferredContentSizeCategory.self]
        ) { (self: Self, previous: UITraitCollection) in
            self.tableView.reloadData()
        }
    }
    
    public override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()

        tableView.sizeTableHeaderToFit()
    }
    
    private func configureTableView() {
        dataSource.defaultRowAnimation = .fade
        tableView.dataSource = dataSource
        tableView.tableHeaderView = errorView.makeContainer()
        registerCells()

        errorView.onHide = { [weak self] in
            self?.tableView.beginUpdates()
            self?.tableView.sizeTableHeaderToFit()
            self?.tableView.endUpdates()
        }
    }
    
    private func registerCells() {
        cells.forEach { cell in
            tableView.register(cell.self, forCellReuseIdentifier: String(describing: cell.self))
        }
    }
    
    @IBAction private func refresh() {
        onRefresh?()
    }
    
    public func display(_ cellControllers: [CellController]) {
        var snapshot = NSDiffableDataSourceSnapshot<Int, CellController>()
        snapshot.appendSections([0])
        snapshot.appendItems(cellControllers, toSection: 0)
        dataSource.applySnapshotUsingReloadData(snapshot)
    }

    public func display(_ viewModel: ResourceLoadingViewModel) {
        if tableView.numberOfSections == 0 {
         print("empty")
        }
        refreshControl?.update(isRefreshing: viewModel.isLoading)
    }
    
    public override func viewIsAppearing(_ animated: Bool) {
        super.viewIsAppearing(animated)

        onViewIsAppearing?(self)
    }
    
    public func display(_ viewModel: ResourceErrorViewModel) {
        errorView.message = viewModel.message
    }
    
    public override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let dl = cellController(at: indexPath)?.delegate
        dl?.tableView?(tableView, didSelectRowAt: indexPath)
    }
    
    public override func tableView(_ tableView: UITableView, willDisplay cell: UITableViewCell, forRowAt indexPath: IndexPath) {
      let dl = cellController(at: indexPath)?.delegate
      dl?.tableView?(tableView, willDisplay: cell, forRowAt: indexPath)
    }
    
    public override func tableView(_ tableView: UITableView, didEndDisplaying cell: UITableViewCell, forRowAt indexPath: IndexPath) {
        let dl = cellController(at: indexPath)?.delegate
        dl?.tableView?(tableView, didEndDisplaying: cell, forRowAt: indexPath)
    }
    
    
    public func tableView(_ tableView: UITableView, prefetchRowsAt indexPaths: [IndexPath]) {
        indexPaths.forEach { indexPath in
            let dsp = cellController(at: indexPath)?.dataSourcePrefetching
            dsp?.tableView(tableView, prefetchRowsAt: [indexPath])
        }
    }
    
    public func tableView(_ tableView: UITableView, cancelPrefetchingForRowsAt indexPaths: [IndexPath]) {
        indexPaths.forEach { indexPath in
            let dsp = cellController(at: indexPath)?.dataSourcePrefetching
            dsp?.tableView?(tableView, cancelPrefetchingForRowsAt: [indexPath])
        }
    }

    
    private func cellController(at indexPath: IndexPath) -> CellController? {
        dataSource.itemIdentifier(for: indexPath)
    }
}

final public class RefreshViewController: NSObject {
   public lazy var view: UIRefreshControl = {
        let view = UIRefreshControl()
        view.addTarget(self, action: #selector(refresh), for: .valueChanged)
        return view
    }()

    public var onRefresh: (() -> ())?

    @objc func refresh() {
        onRefresh?()
    }
}
