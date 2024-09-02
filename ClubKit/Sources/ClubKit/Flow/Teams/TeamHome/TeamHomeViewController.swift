//
//  TeamHomeViewController.swift
//  
//
//  Created by Findlay-Personal on 27/05/2023.
//

import UIKit

class TeamHomeViewController: UIViewController {

    var coordinator: TeamFlow?
    
    var viewModel: TeamHomeViewModel
    var display: TeamHomeView!
    
    init(viewModel: TeamHomeViewModel) {
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
        initViewModel()
        view.backgroundColor = .systemBackground
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        navigationController?.navigationBar.isHidden = false
        navigationItem.title = viewModel.team.teamName
        editNavBarColour(to: .darkColour)
    }
    
    func addDisplay() {
        display = .init(viewModel: viewModel)
        addSwiftUIView(display)
    }
    
    // MARK: - View Model
    func initViewModel() {
        viewModel.selectedAction = { [weak self] action in
            guard let self else { return }
            switch action {
            case .players:
                self.coordinator?.goToPlayers(self.viewModel.team)
            case .defaultLineup:
                self.coordinator?.goToDefaultLineup(self.viewModel.team)
            }
        }
    }
}
