//
//  GroupAddPlayersViewController.swift
//  InTheGym
//
//  Created by Findlay Wood on 09/08/2021.
//  Copyright © 2021 FindlayWood. All rights reserved.
//

import UIKit

class GroupAddPlayersViewController: UIViewController {
    
    var delegate: AddedPlayersProtocol!
    
    var display = GroupAddPlayersView()
    
    var apiService = FirebaseLoadingUsersService.shared
    
    var adapter: GroupAddPlayersAdapter!
    
    lazy var viewModel: GroupAddPlayersViewModel = {
        return GroupAddPlayersViewModel(apiService: apiService)
    }()

    override func viewDidLoad() {
        super.viewDidLoad()
        initDisplay()
        initViewModel()
        let button = UIBarButtonItem(barButtonSystemItem: .done, target: self, action: #selector(finished))
        navigationItem.rightBarButtonItem = button
        navigationItem.rightBarButtonItem?.isEnabled = false
    }
    
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        display.frame = CGRect(x: 0, y: view.safeAreaInsets.top, width: view.frame.width, height: view.frame.height - view.safeAreaInsets.top)
        view.addSubview(display)
    }
    
    func initViewModel() {
        viewModel.updateLoadingStatucClosure = { [weak self] in
            guard let self = self else {return}
            DispatchQueue.main.async {
                let isLoading = self.viewModel.isLoading
                if isLoading {
                    self.display.loadingIndicator.startAnimating()
                    UIView.animate(withDuration: 0.2, animations: {
                        self.display.tableview.alpha = 0.0
                    })
                } else {
                    self.display.loadingIndicator.stopAnimating()
                    UIView.animate(withDuration: 0.2, animations: {
                        self.display.tableview.alpha = 1.0
                    })
                }
            }
        }
        
        viewModel.reloadTableViewClosure = { [weak self] in
            guard let self = self else {return}
            DispatchQueue.main.async {
                self.display.tableview.reloadData()
            }
        }
        
        viewModel.errorReturnedClosure = { returnedError in
            print(returnedError.localizedDescription)
        }
        
        viewModel.fetchPlayers()
    }
    
    @objc func finished() {
        
    }

}

// MARK: - Display Configuration
extension GroupAddPlayersViewController {
    func initDisplay() {
        adapter = GroupAddPlayersAdapter(delegate: self)
        display.tableview.delegate = adapter
        display.tableview.dataSource = adapter
    }
}

// MARK: - Protocol Methods
extension GroupAddPlayersViewController: GroupAddPlayersProtocol {
    func getPlayerData(at indexPath: IndexPath) -> Users {
        return viewModel.getData(at: indexPath)
    }
    func numberOfPlayers() -> Int {
        return viewModel.numberOfPlayers
    }
    func playerSelected(at indexPath: IndexPath) {
        
    }
}

