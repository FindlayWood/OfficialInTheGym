//
//  TeamsViewController.swift
//  
//
//  Created by Findlay-Personal on 21/05/2023.
//

import UIKit

class TeamsViewController: UIViewController {
    
    var coordinator: TeamFlow?
    
    var viewModel: TeamsViewModel
    var display: TeamsView!
    
    init(viewModel: TeamsViewModel) {
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
        initNavBar()
        view.backgroundColor = .systemBackground
        initViewModel()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        navigationController?.navigationBar.isHidden = false
        navigationItem.title = "\(viewModel.clubModel.clubName)'s teams"
        editNavBarColour(to: .darkColour)
    }
    
    // MARK: - Nav bar
    func initNavBar() {
        let barButton = UIBarButtonItem(image: UIImage(systemName: "plus.circle.fill"), style: .done, target: self, action: #selector(addNewTeam))
        navigationItem.rightBarButtonItem = barButton
    }
    
    // MARK: - Display
    func addDisplay() {
        display = .init(viewModel: viewModel)
        addSwiftUIView(display)
    }
    
    // MARK: - Actions
    @objc func addNewTeam(_ sender: UIBarButtonItem) {
        coordinator?.addNewTeam()
    }
    
    // MARK: - View Model
    func initViewModel() {
        viewModel.selectedTeam = { [weak self] selected in
            self?.coordinator?.goToTeam(selected)
        }
    }
}
