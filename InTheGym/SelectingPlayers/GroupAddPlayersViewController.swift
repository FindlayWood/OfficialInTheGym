//
//  GroupAddPlayersViewController.swift
//  InTheGym
//
//  Created by Findlay Wood on 09/08/2021.
//  Copyright © 2021 FindlayWood. All rights reserved.
//

import UIKit

class GroupAddPlayersViewController: UIViewController {
    
    var delegate: SelectPlayersProtocol!
    
    var display = GroupAddPlayersView()
    
    var apiService = FirebaseLoadingUsersService.shared
    
    var adapter: GroupAddPlayersAdapter!
    
    var alreadySelectedPlayers: [Users] = []
    
    lazy var viewModel: GroupAddPlayersViewModel = {
        return GroupAddPlayersViewModel(apiService: apiService)
    }()

    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = Constants.offWhiteColour
        initDisplay()
        initViewModel()
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
        viewModel.selectedPlayers = alreadySelectedPlayers
        viewModel.fetchPlayers()
    }
    
    @objc func finished() {
        delegate.playersSelected(viewModel.selectedPlayers)
        self.dismiss(animated: true, completion: nil)
    }

}

// MARK: - Display Configuration
extension GroupAddPlayersViewController {
    func initDisplay() {
        adapter = GroupAddPlayersAdapter(delegate: self)
        display.tableview.delegate = adapter
        display.tableview.dataSource = adapter
        display.tableview.backgroundColor = Constants.offWhiteColour
        display.dismissButton.addTarget(self, action: #selector(finished), for: .touchUpInside)
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
    func checkIfPlayerSelected(_ player: Users) -> Bool {
        return viewModel.checkIfPlayerSelected(player)
    }
    func playerSelected(at indexPath: IndexPath) {
        let cell = display.tableview.cellForRow(at: indexPath)
        if cell?.accessoryType == UITableViewCell.AccessoryType.none {
            cell?.accessoryType = .checkmark
            viewModel.playerSelected(at: indexPath)
            display.tableview.reloadData()
        } else {
            cell?.accessoryType = .none
            viewModel.playerDeselected(at: indexPath)
            display.tableview.reloadData()
        }
    }
}

