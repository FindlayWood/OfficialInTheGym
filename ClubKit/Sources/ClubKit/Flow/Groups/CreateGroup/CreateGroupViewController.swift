//
//  CreateGroupViewController.swift
//  
//
//  Created by Findlay Wood on 19/11/2023.
//

import UIKit

class CreateGroupViewController: UIViewController {

    var coordinator: GroupFlow?
    
    var viewModel: CreateGroupViewModel
    var display: CreateGroupView!
    
    init(viewModel: CreateGroupViewModel) {
        self.viewModel = viewModel
        super.init(nibName: nil, bundle: nil)
    }
    
    @available(*, unavailable)
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        addDisplay()
        view.backgroundColor = .systemBackground
        initViewModel()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        navigationController?.navigationBar.isHidden = false
        navigationItem.title = "Create Group"
        editNavBarColour(to: .darkColour)
    }
    
    // MARK: - Display
    func addDisplay() {
        display = .init(viewModel: viewModel)
        addSwiftUIView(display)
    }
    
    // MARK: - View Model
    func initViewModel() {
        viewModel.selectedPlayers = { [weak self] in
            guard let self else { return }
            self.selectPlayers()
        }
    }
    
    func selectPlayers() {
        coordinator?.selectPlayersForNewGroup(alreadySelected: viewModel.selectedPlayersList) { [weak self] selectedPlayers in
            self?.viewModel.addPlayers(selectedPlayers)
            self?.navigationController?.dismiss(animated: true)
        }
    }
}
