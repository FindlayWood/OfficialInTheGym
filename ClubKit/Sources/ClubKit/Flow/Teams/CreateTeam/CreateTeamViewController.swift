//
//  CreateTeamViewController.swift
//  
//
//  Created by Findlay Wood on 01/10/2023.
//

import UIKit

class CreateTeamViewController: UIViewController {
    
    var coordinator: TeamFlow?
    
    var viewModel: CreateTeamViewModel
    var display: CreateTeamView!
    
    
    init(viewModel: CreateTeamViewModel) {
        self.viewModel = viewModel
        
        super.init(nibName: nil, bundle: nil)
    }
    
    @available(*, unavailable)
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .systemBackground
        addDisplay()
        initViewModel()
    }
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        navigationController?.navigationBar.isHidden = false
        navigationItem.title = "Create New Team"
        editNavBarColour(to: .darkColour)
    }
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
        coordinator?.selectPlayersForNewTeam(alreadySelected: viewModel.selectedPlayersList) { [weak self] selectedPlayers in
            self?.viewModel.addPlayers(selectedPlayers)
            self?.navigationController?.dismiss(animated: true)
        }
    }
}
