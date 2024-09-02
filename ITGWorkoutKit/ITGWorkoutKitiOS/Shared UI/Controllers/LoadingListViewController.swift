//
//  LoadingListViewController.swift
//  ITGWorkoutKitiOS
//
//  Created by Findlay Wood on 21/07/2024.
//

import UIKit
import ITGWorkoutKit

public final class LoadingListViewController: UITableViewController, UITableViewDataSourcePrefetching, ResourceLoadingView, ResourceErrorView {
    public var onRefresh: (() -> Void)?
    public var cells: [UITableViewCell.Type] = [UITableViewCell.Type]()
    public var rightBarButtons: [UIBarButtonItem] = [UIBarButtonItem]()
    
    public var refreshController = RefreshViewController()
    public var errorView: LoadingView = DefaultErrorUIView()
    public var loadingView: LoadingView = DefaultLoadingUIView()
    var emptyListView: LoadingView = DefaultEmptyListUIView()
    
    
    private lazy var dataSource: UITableViewDiffableDataSource<Int, CellController> = {
         .init(tableView: tableView) { (tableView, index, controller) in
             controller.dataSource.tableView(tableView, cellForRowAt: index)
         }
     }()
    
    private var onViewIsAppearing: ((LoadingListViewController) -> ())?
    
    public override func viewDidLoad() {
        super.viewDidLoad()
        
        configureTableView()
        configureTraitCollectionObservers()
        configureBarButtons()
        
        refreshControl = UIRefreshControl()
        refreshControl?.addTarget(self, action: #selector(refresh), for: .valueChanged)
        
        refreshController.onRefresh = { [weak self] in
            self?.onRefresh?()
        }
        
        onViewIsAppearing = { vc in
            vc.onViewIsAppearing = nil
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
        configureErrorView()
        configureLoadingView()
        configureEmptyListView()
    }
    
    private func configureErrorView() {
        view.addSubview(errorView)
        errorView.frame = CGRect(x: 0, y: 0, width: view.frame.width, height: view.frame.height - view.safeAreaInsets.top)
    }
    
    private func configureLoadingView() {
        view.addSubview(loadingView)
        loadingView.frame = CGRect(x: 0, y: 0, width: view.frame.width, height: view.frame.height - view.safeAreaInsets.top)
    }
    
    private func configureEmptyListView() {
        view.addSubview(emptyListView)
        emptyListView.frame = CGRect(x: 0, y: 0, width: view.frame.width, height: view.frame.height - view.safeAreaInsets.top)
    }
    
    private func configureTableView() {
        dataSource.defaultRowAnimation = .fade
        tableView.dataSource = dataSource
        registerCells()
    }
    
    private func registerCells() {
        cells.forEach { cell in
            tableView.register(cell.self, forCellReuseIdentifier: String(describing: cell.self))
        }
    }
    
    private func configureBarButtons() {
        navigationController?.navigationItem.rightBarButtonItems = rightBarButtons
//        navigationItem.rightBarButtonItems = rightBarButtons
    }
    
    @objc private func refresh() {
        onRefresh?()
    }
    
    public func display(_ cellControllers: [CellController]) {
        if cellControllers.isEmpty {
            emptyListView.showAnimated()
        } else {
            emptyListView.hide()
            var snapshot = NSDiffableDataSourceSnapshot<Int, CellController>()
            snapshot.appendSections([0])
            snapshot.appendItems(cellControllers, toSection: 0)
            dataSource.applySnapshotUsingReloadData(snapshot)
        }
    }

    public func display(_ viewModel: ResourceLoadingViewModel) {
        if tableView.numberOfSections == 0 {
            loadingView.showAnimated()
        } else {
            loadingView.hide()
            refreshControl?.update(isRefreshing: viewModel.isLoading)
        }
    }
    
    public override func viewIsAppearing(_ animated: Bool) {
        super.viewIsAppearing(animated)

        onViewIsAppearing?(self)
    }
    
    public func display(_ viewModel: ResourceErrorViewModel) {
        if let _ = viewModel.message {
            errorView.showAnimated()
        } else {
            errorView.hide()
        }
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
